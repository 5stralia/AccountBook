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
        self.user.flatMap { [weak self] user -> Single<[String]> in
            guard let self = self,
                  let user = user else { return Single.never() }
            return self.api.groupIDs(uid: user.uid)
        }
        .compactMap { $0.first }
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
            self?.requestAccounts()
            self?.requestMembers()
        })
            .disposed(by: self.disposeBag)
    }
    
    func requestAccounts() {
        guard let gid = try? self.group.gid.value() else { return }
        
        self.api.requestAccounts(gid: gid).asObservable()
            .subscribe(onNext: { [weak self] accounts in
                self?.group.accounts.onNext(accounts)
            })
            .disposed(by: self.disposeBag)
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
                self?.group.members.onNext(members)
            })
            .disposed(by: self.disposeBag)
    }
}
