//
//  EdittingNameViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/06.
//

import UIKit

import RxSwift
import RxCocoa

class EdittingNameViewController: ViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var peopleCountLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userImageAddButton: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    
    
    override func bind(to viewModel: ViewModel) {
        guard let viewModel = viewModel as? EdittingNameViewModel else { return }
        
        self.backButton.rx.tap.asObservable().subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        })
        .disposed(by: self.disposeBag)
        
        let output = viewModel.transform(input: EdittingNameViewModel.Input(
                                            editName: self.submitButton.rx.tap.asObservable(),
                                            nameText: self.userNameTextField.rx.text.orEmpty.asObservable()))
        
        output.groupNameText.bind(to: self.groupNameLabel.rx.text).disposed(by: self.disposeBag)
        output.peopleCountText.bind(to: self.peopleCountLabel.rx.text).disposed(by: self.disposeBag)
        output.feeText.bind(to: self.feeLabel.rx.text).disposed(by: self.disposeBag)
    }

}
