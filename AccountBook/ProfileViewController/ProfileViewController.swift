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

class ProfileViewController: ViewController {
    
    override func bind(to viewModel: ViewModel) {
        guard let viewModel = viewModel as? ProfileViewModel else { return }
        
        let output = viewModel.transform(
            input: ProfileViewModel.Input(viewWillAppear: self.rx.viewWillAppear.asObservable().map { _ in }))
        
        output.group
            .compactMap { $0?.name }
            .bind(to: self.rx.title)
            .disposed(by: self.disposeBag)

    }
}
