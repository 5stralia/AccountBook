//
//  AccountDetailSelectionCell.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/28.
//

import UIKit

import RxCocoa
import RxSwift

class AccountDetailSelectionCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    var disposeBag = DisposeBag()
    
    func bind(to viewModel: AccountDetailSelectionCellViewModel) {
        viewModel.title.bind(to: self.titleLabel.rx.text).disposed(by: self.disposeBag)
        viewModel.value.bind(to: self.valueLabel.rx.text).disposed(by: self.disposeBag)
    }
}
