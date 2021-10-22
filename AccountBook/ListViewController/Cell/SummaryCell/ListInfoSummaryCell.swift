//
//  ListInfoSummaryCell.swift
//  AccountBook
//
//  Created by 최호주 on 2021/10/22.
//

import UIKit

import RxCocoa
import RxSwift

class ListInfoSummaryCell: UITableViewCell {
    @IBOutlet weak var amountLabel: UILabel!
    
    var disposeBag = DisposeBag()
    
    func bind(to viewModel: ListInfoSummaryCellViewModel) {
        viewModel.amount.bind(to: self.amountLabel.rx.text).disposed(by: self.disposeBag)
    }
}
