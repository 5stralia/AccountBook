//
//  TableViewCell.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import UIKit

import RxSwift
import RxCocoa

class TableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var accesoryImageView: UIImageView!
    
    var disposeBag = DisposeBag()
    
    func bind(to viewModel: TableViewCellViewModel) {
        viewModel.title.asDriver().drive(self.titleLabel.rx.text).disposed(by: self.disposeBag)
        viewModel.detail.asDriver().drive(self.detailLabel.rx.text).disposed(by: self.disposeBag)
        viewModel.isHiddenAccesoryImageView.asDriver().drive(self.accesoryImageView.rx.isHidden).disposed(by: self.disposeBag)
    }
}
