//
//  EdittingGroupViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/30.
//

import UIKit

import RxSwift
import RxCocoa

class EdittingGroupViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageSetButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var feeTextField: UITextField!
    @IBOutlet weak var feeTypeButton: UIButton!
    @IBOutlet weak var feeDayButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var calculateDayButton: UIButton!
    
    var viewModel: EdittingGroupViewModel? {
        willSet {
            if let edittingGroupViewModel = newValue {
                self.rx.viewDidLoad.asObservable().map { _ in }
                    .subscribe(onNext: { [weak self] in
                        self?.bind(to: edittingGroupViewModel)
                    })
                    .disposed(by: self.dispostBag)
            }
        }
    }
    
    var dispostBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = true
    }

    private func bind(to viewModel: EdittingGroupViewModel) {
        self.backButton.rx.tap.asObservable().map { _ in }
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: self.dispostBag)
        
        let feeType = Observable.just(FeeType.monthly)
        let feeDay = Observable.just(1)
        let calculateDay = Observable.just(1)
        
        let output = viewModel.transform(
            input: EdittingGroupViewModel.Input(
                image: self.imageView.rx.observe(Optional<UIImage>.self, "image").compactMap({ $0??.pngData() }).asDriver(onErrorJustReturn: Data()),
                name: self.nameTextField.rx.text.orEmpty.asDriver(),
                fee: self.feeTextField.rx.text.orEmpty.compactMap({ Int($0) }).asDriver(onErrorJustReturn: 0),
                message: self.messageTextField.rx.text.orEmpty.asDriver(),
                feeTypeSelection: feeType.asDriver(onErrorJustReturn: .monthly),
                feeDaySelection: feeDay.asDriver(onErrorJustReturn: 1),
                calculateDaySelection: calculateDay.asDriver(onErrorJustReturn: 1),
                createGroup: self.submitButton.rx.tap.asDriver()))
        
        output.shouldSubmit.bind(to: self.submitButton.rx.isEnabled).disposed(by: self.dispostBag)
        
        output.close.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.dispostBag)
        
        output.alert.asObservable()
            .subscribe(onNext: { [weak self] message in
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                
                self?.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: self.dispostBag)
    }
}
