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
    var name: BehaviorSubject<String?>
    var user: BehaviorSubject<User?>
    
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    init(user: User?) {
        self.uid = BehaviorSubject<String?>(value: user?.uid)
        self.name = BehaviorSubject<String?>(value: user?.displayName)
        self.user = BehaviorSubject<User?>(value: user)
    }
    
    func addStateDidChangeListener() {
        self.authHandle = Auth.auth().addStateDidChangeListener { auth, user in
            self.uid.onNext(user?.uid)
            self.name.onNext(user?.displayName)
            self.user.onNext(user)
        }
    }
    
    func removeStateDidChangeListener() {
        if let handle = self.authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
}
