//
//  MonthlyChartCell.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import UIKit

import RxCocoa
import RxSwift

class MonthlyChartCell: UICollectionViewCell {
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var barBackgroundView: UIView!
    
    @IBOutlet weak var barHeightConstraint: NSLayoutConstraint!
    
    var disposeBag = DisposeBag()
    
    func bind(to viewModel: MonthlyChartCellViewModel) {
        viewModel.amount.bind(to: self.amountLabel.rx.text).disposed(by: self.disposeBag)
        viewModel.progress
            .withUnretained(self)
            .map { own, progress in
                let labelHeight: CGFloat = 20
                return (own.barBackgroundView.bounds.height - labelHeight) * CGFloat(progress)
            }
            .bind(to: self.barHeightConstraint.rx.constant)
            .disposed(by: self.disposeBag)
        viewModel.month.bind(to: self.monthLabel.rx.text).disposed(by: self.disposeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
    
}
