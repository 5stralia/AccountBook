//
//  TitleValueCell.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/28.
//

import UIKit

import RxCocoa
import RxSwift

class AccountDetailDateCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var disposeBag = DisposeBag()
    
    func bind(to viewModel: AccountDetailDateCellViewModel) {
        viewModel.title.bind(to: self.titleLabel.rx.text).disposed(by: self.disposeBag)
        viewModel.date.bind(to: self.datePicker.rx.date).disposed(by: self.disposeBag)
    }
}
