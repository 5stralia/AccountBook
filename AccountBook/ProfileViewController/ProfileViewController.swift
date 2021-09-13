//
//  ProfileViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import UIKit

import Firebase
import RxSwift
import RxCocoa

class ProfileViewController: UIViewController {
    @IBOutlet weak var signOutButton: UIButton!
    
    var viewModel: ProfileViewModel? {
        willSet {
            if let profileViewModel = newValue {
                self.bind(to: profileViewModel)
            }
        }
    }
    
    var disposeBag = DisposeBag()
    
    private func bind(to viewModel: ProfileViewModel) {
        let output = viewModel.transform(
            input: ProfileViewModel.Input(viewWillAppear: self.rx.viewWillAppear
                                            .asObservable()
                                            .map { _ in }))
    }
}
