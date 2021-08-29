//
//  ProfileViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import UIKit

import Firebase
import GoogleSignIn

class ProfileViewController: UIViewController {
    @IBOutlet weak var signOutButton: UIButton!
    
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.authHandle = Auth.auth().addStateDidChangeListener { auth, user in
            // 로그인 상태 변경 리스너
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let handle = self.authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
