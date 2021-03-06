//
//  ABProvider.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/20.
//

import Foundation

import Firebase
import RxSwift

enum ABProviderError: Error {
    case invalidGID
    case invalidUID
    case invalidUser
}

final class ABProvider {
    let api: ABAPI
    
    let user: BehaviorSubject<User?>
    let group = Group()
    
    var disposeBag = DisposeBag()
    
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    init(api: ABAPI) {
        self.user = BehaviorSubject<User?>(value: nil)
        self.api = api
        
        self.authHandle = Auth.auth().addStateDidChangeListener { auth, user in
            self.user.onNext(user)
        }
    }
    
    deinit {
        if let handle = self.authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func setUP() {
        let user = user.share()
        user
            .compactMap { $0?.uid }
            .flatMap({ uid -> Completable in
                return self.api.registerIfNewUser(uid: uid)
            })
            .subscribe({ event in
                print(event)
            })
            .disposed(by: disposeBag)
        user.flatMap { [weak self] user -> Single<[String]> in
            guard let self = self,
                  let user = user else { return Single.never() }
            return self.api.groupIDs(uid: user.uid)
        }
        .compactMap { $0.first }
        .debug()
        .bind(to: self.group.gid)
        .disposed(by: self.disposeBag)
        
        self.group.gid
        .flatMap { [weak self] gid -> Single<GroupDocumentModel?> in
            guard let self = self, let gid = gid else { return Single.never() }
            return self.api.group(groupID: gid)
        }
        .bind(to: self.group.groupDocumentModel)
        .disposed(by: self.disposeBag)
        
        self.group.gid.subscribe(onNext: { [weak self] gid in
            guard let _ = gid else { return }
            self?.requestMembers()
        })
            .disposed(by: self.disposeBag)
    }
    
    func requestAccounts(startDate: Date? = nil, endDate: Date? = nil) -> Single<[AccountDocumentModel]> {
        guard let gid = try? self.group.gid.value() else { return .never() }
        
        return self.api.requestAccounts(gid: gid, startDate: startDate, endDate: endDate)
    }
    
    func append(account: AccountDocumentModel) -> Completable {
        guard let gid = try? self.group.gid.value() else { return .error(ABProviderError.invalidGID) }
        
        let appendAccount = self.api.append(gid: gid, account: account).asObservable().share().asCompletable()
        
        appendAccount.subscribe(onCompleted: { [weak self] in
            guard let self = self,
                  let accounts = try? self.group.accounts.value()
            else { return }
            
            self.group.accounts.onNext(accounts + [account])
        })
            .disposed(by: self.disposeBag)
        
        return appendAccount
    }
    
    func requestMembers() {
        guard let gid = try? self.group.gid.value() else { return }
        
        self.api.requestMembers(gid: gid).asObservable()
            .subscribe(onNext: { [weak self] members in
                print(members)
                self?.group.members.onNext(members)
            })
            .disposed(by: self.disposeBag)
    }
    
    func createInvitation() -> Single<String> {
        guard let gid = try? group.gid.value() else { return .error(ABProviderError.invalidGID) }
        
        return api.createInvitation(gid: gid)
    }
    
    func requestJoin(id: String) -> Completable {
        guard let user = try? user.value(),
              let name = user.displayName else { return .error(ABProviderError.invalidUser) }
        return api.requestJoin(id: id, member: MemberDocumentModel(uid: user.uid,
                                                                   name: name,
                                                                   role: [.read]))
    }
}
