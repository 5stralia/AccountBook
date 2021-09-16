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
    @IBOutlet weak var groupNameLabel: UILabel!
    
    var viewModel: ProfileViewModel? {
        willSet {
            if let profileViewModel = newValue {
                self.rx.viewDidLoad.subscribe(onNext: { [weak self] in
                    self?.bind(to: profileViewModel)
                })
                .disposed(by: self.disposeBag)
            }
        }
    }
    
    var disposeBag = DisposeBag()
    
    private func bind(to viewModel: ProfileViewModel) {
        let output = viewModel.transform(
            input: ProfileViewModel.Input(viewWillAppear: self.rx.viewWillAppear
                                            .asObservable()
                                            .map { _ in }))
        
        output.group
            .compactMap { $0?.name }
            .bind(to: self.groupNameLabel.rx.text)
            .disposed(by: self.disposeBag)
    }
}
