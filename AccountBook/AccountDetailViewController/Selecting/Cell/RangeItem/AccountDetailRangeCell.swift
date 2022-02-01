//
//  AccountDetailRangeCell.swift
//  AccountBook
//
//  Created by Hoju Choi on 2022/01/05.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import TTRangeSlider

final class AccountDetailRangeCell: UITableViewCell {
    let slider = TTRangeSlider()
    
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }
    
    private func configure() {
        self.contentView.addSubview(self.slider)
        slider.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.trailing.equalToSuperview().offset(-10)
        }
    }
    
    func bind(to viewModel: AccountDetailRangeCellViewModel<Int>) {
        viewModel.min
            .withUnretained(self)
            .subscribe(onNext: { own, minValue in own.slider.minValue = Float(minValue) })
            .disposed(by: self.disposeBag)
        viewModel.min
            .take(1)
            .withUnretained(self)
            .subscribe(onNext: { own, minValue in own.slider.selectedMinimum = Float(minValue) })
            .disposed(by: self.disposeBag)
        viewModel.max
            .withUnretained(self)
            .subscribe(onNext: { own, maxValue in own.slider.maxValue = Float(maxValue) })
            .disposed(by: self.disposeBag)
        viewModel.max
            .take(1)
            .withUnretained(self)
            .subscribe(onNext: { own, maxValue in own.slider.selectedMaximum = Float(maxValue) })
            .disposed(by: self.disposeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
}
