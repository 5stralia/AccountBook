//
//  ABUser.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/06.
//

import Foundation

import Firebase
import RxSwift

final class ABUser {
    var uid: BehaviorSubject<String?>
    
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    init(uid: String?) {
        self.uid = BehaviorSubject<String?>(value: uid)
    }
    
    func addStateDidChangeListener() {
        self.authHandle = Auth.auth().addStateDidChangeListener { auth, user in
            self.uid.onNext(user?.uid)
        }
    }
    
    func removeStateDidChangeListener() {
        if let handle = self.authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
}
