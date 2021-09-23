//
//  ListAccountCell.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/23.
//

import UIKit

import RxCocoa
import RxSwift

class ListAccountCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    var disposeBag = DisposeBag()
    
    func bind(to viewModel: ListAccountCellViewModel) {
        viewModel.date.bind(to: self.dateLabel.rx.text).disposed(by: self.disposeBag)
        viewModel.category.bind(to: self.categoryLabel.rx.text).disposed(by: self.disposeBag)
        viewModel.title.bind(to: self.titleLabel.rx.text).disposed(by: self.disposeBag)
        viewModel.amount.bind(to: self.amountLabel.rx.text).disposed(by: self.disposeBag)
    }
}
