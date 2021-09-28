//
//  AccountDetailSegmentCell.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/28.
//

import UIKit

import RxRelay
import RxSwift

class AccountDetailSegmentCell: UITableViewCell {
    @IBOutlet weak var segment: UISegmentedControl!
    
    var disposeBag = DisposeBag()
    
    func bind(to viewModel: AccountDetailSegmentCellViewModel) {
        viewModel.selectedIndex.bind(to: self.segment.rx.value).disposed(by: self.disposeBag)
    }
}
