//
//  ProfileMembersViewController.swift
//  AccountBook
//
//  Created by Hoju Choi on 2022/02/09.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class ProfileMembersViewController: ViewController {
    
    override func bind(to viewModel: ViewModel) {
        guard let viewModel = viewModel as? ProfileMembersViewModel else { return }
        
        let output = viewModel.transform(input: ProfileMembersViewModel.Input())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
}
