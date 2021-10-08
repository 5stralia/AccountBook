//
//  TextFieldCell.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import UIKit

import RxRelay
import RxSwift

class TextFieldCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
    
    var disposeBag = DisposeBag()
    
    func bind(to viewModel: TextFieldCellViewModel) {
        self.textField.text = viewModel.text.value
        self.textField.rx.text.distinctUntilChanged().bind(to: viewModel.text).disposed(by: self.disposeBag)
        viewModel.placeholderText.bind(to: self.textField.rx.placeholder).disposed(by: self.disposeBag)
    }
}
