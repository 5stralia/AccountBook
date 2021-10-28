//
//  EdittingGroupViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/30.
//

import UIKit

import RxSwift
import RxCocoa

class EdittingGroupViewController: ViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageSetButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var feeTextField: UITextField!
    @IBOutlet weak var feeTypeButton: UIButton!
    @IBOutlet weak var feeDayButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var calculateDayButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
        self.navigationController?.navigationBar.isHidden = false
    }

    override func bind(to viewModel: ViewModel) {
        guard let viewModel = viewModel as? EdittingGroupViewModel else { return }
        
        let feeType = Observable.just(FeeType.monthly)
        let feeDay = Observable.just(1)
        let calculateDay = Observable.just(1)
        
        let output = viewModel.transform(
            input: EdittingGroupViewModel.Input(
                image: self.imageView.rx.observe(Optional<UIImage>.self, "image").compactMap({ $0??.pngData() }).asDriver(onErrorJustReturn: Data()),
                name: self.nameTextField.rx.text.distinctUntilChanged().asDriver(onErrorJustReturn: nil),
                fee: self.feeTextField.rx.text.distinctUntilChanged().map {
                    if let text = $0, let fee = Int(text) {
                        return fee
                    } else {
                        return nil
                    }
                }.asDriver(onErrorJustReturn: 0),
                message: self.messageTextField.rx.text.distinctUntilChanged().asDriver(onErrorJustReturn: nil),
                feeTypeSelection: feeType.asDriver(onErrorJustReturn: .monthly),
                feeDaySelection: feeDay.asDriver(onErrorJustReturn: 1),
                calculateDaySelection: calculateDay.asDriver(onErrorJustReturn: 1),
                createGroup: self.navigationItem.rightBarButtonItem!.rx.tap.asDriver()))
        
        output.shouldSubmit.bind(to: self.navigationItem.rightBarButtonItem!.rx.isEnabled).disposed(by: self.disposeBag)
        
        output.alert.asObservable()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] message in
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                
                self?.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
    }
}
