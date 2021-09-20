//
//  ABProvider.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/20.
//

import Foundation

import Firebase
import RxSwift

final class ABProvider {
    let user: BehaviorSubject<User?>
    let api: ABAPI
    
    let group = Group()
    
    var disposeBag = DisposeBag()
    
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    init(user: User?, api: ABAPI) {
        self.user = BehaviorSubject<User?>(value: user)
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
        .flatMap { [weak self] gids -> Single<GroupDocumentModel?> in
            guard let self = self,
                  let gid = gids.first else { return Single.never() }
            return self.api.group(groupID: gid)
        }
        .bind(to: self.group.groupDocumentModel)
        .disposed(by: self.disposeBag)
    }
}
