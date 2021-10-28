//
//  EdittingTitleViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/30.
//

import UIKit

import RxSwift
import RxCocoa

class IntroCreatingGroupViewController: ViewController {
    @IBOutlet weak var startButton: UIButton!
    
    override func bind(to viewModel: ViewModel) {
        guard let viewModel = viewModel as? IntroCreatingGroupViewModel else { return }
        
        let output = viewModel.transform(
            input: IntroCreatingGroupViewModel.Input(tappedStartButton: self.startButton.rx.tap.asDriver()))
        
        output.presentEdittingGroup.drive(onNext: { [weak self] creatingGroupViewModel in
            let creatingGroupViewController = EdittingGroupViewController()
            creatingGroupViewController.viewModel = creatingGroupViewModel
            self?.navigationController?.pushViewController(creatingGroupViewController, animated: true)
        })
        .disposed(by: self.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
}
