//
//  ViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/02.
//

import UIKit

import RxSwift

class ViewController: UIViewController {
    
    var viewModel: ViewModel? {
        willSet {
            if let viewModel = newValue {
                if self.isViewLoaded {
                    self.bind(to: viewModel)
                } else {
                    self.rx.viewDidLoad.asObservable().subscribe(onNext: { [weak self] _ in
                        self?.bind(to: viewModel)
                    })
                        .disposed(by: self.disposeBag)
                }
            }
        }
    }
    
    var disposeBag = DisposeBag()
    
    func bind(to viewModel: ViewModel) {
        
    }
}
