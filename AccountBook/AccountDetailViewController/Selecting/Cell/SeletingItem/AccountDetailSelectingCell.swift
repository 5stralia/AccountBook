//
//  AccountDetailSelectingCell.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/30.
//

import UIKit

import RxCocoa
import RxSwift

class AccountDetailSelectingCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightImageView: UIImageView!
    
    var disposeBag = DisposeBag()
    
    func bind(to viewModel: AccountDetailSelectingCellViewModel) {
        viewModel.title.bind(to: self.titleLabel.rx.text).disposed(by: self.disposeBag)
        viewModel.isHiddenChevron.bind(to: self.rightImageView.rx.isHidden).disposed(by: self.disposeBag)
    }
}
