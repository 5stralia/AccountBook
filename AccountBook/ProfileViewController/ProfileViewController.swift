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
        
        output.presentIntroCreating.asObservable()
            .subscribe(onNext: { [weak self] introCreatingGroupViewModel in
                let introCreatingGroupViewController = IntroCreatingGroupViewController()
                introCreatingGroupViewController.viewModel = introCreatingGroupViewModel
                let navigationController = UINavigationController(rootViewController: introCreatingGroupViewController)
                navigationController.modalPresentationStyle = .fullScreen
                self?.present(navigationController, animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
    }
}
