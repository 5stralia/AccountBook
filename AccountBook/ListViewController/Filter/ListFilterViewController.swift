//
//  ListFilterViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/10/28.
//

import UIKit

import RxCocoa
import RxSwift

class ListFilterViewController: ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
    }

    override func bind(to viewModel: ViewModel) {
        guard let viewModel = viewModel as? ListFilterViewModel else { return }
        
        self.navigationItem.leftBarButtonItem?.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)

    }

}
