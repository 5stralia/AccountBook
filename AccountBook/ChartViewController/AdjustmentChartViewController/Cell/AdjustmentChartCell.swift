//
//  AdjustmentChartCell.swift
//  AccountBook
//
//  Created by Hoju Choi on 2022/01/22.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class AdjustmentChartCell: UICollectionViewCell {
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        
        return label
    }()
    private let paidAmountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray3
        
        return label
    }()
    private let unpaiedAmountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray3
        
        return label
    }()
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        
        return stackView
    }()
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .right
        
        return label
    }()
    
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.contentView.backgroundColor = .systemBackground
        self.contentView.cornerRadius = 20
        
        self.contentView.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints {
            $0.top.equalTo(self.contentView).offset(15)
            $0.leading.equalTo(self.contentView).offset(20)
        }
        
        self.contentView.addSubview(self.stackView)
        self.stackView.snp.makeConstraints {
            $0.top.equalTo(self.contentView).offset(15)
            $0.leading.greaterThanOrEqualTo(self.nameLabel.snp.trailing).offset(100)
            $0.trailing.equalTo(self.contentView).offset(-15)
        }
        
        let paidStackView = UIStackView()
        paidStackView.axis = .horizontal
        paidStackView.distribution = .fill
        paidStackView.alignment = .fill
        paidStackView.spacing = 8
        
        let paidLabel = UILabel()
        paidLabel.text = "사용"
        paidLabel.font = .systemFont(ofSize: 12)
        paidLabel.textColor = .systemGray3
        
        paidStackView.addArrangedSubview(paidLabel)
        paidLabel.snp.makeConstraints {
            $0.width.equalTo(30)
        }
        
        paidStackView.addArrangedSubview(self.paidAmountLabel)
        
        let unpaidStackView = UIStackView()
        unpaidStackView.axis = .horizontal
        unpaidStackView.distribution = .fill
        unpaidStackView.alignment = .fill
        unpaidStackView.spacing = 8
        
        let unpaidLabel = UILabel()
        unpaidLabel.text = "결제"
        unpaidLabel.font = .systemFont(ofSize: 12)
        unpaidLabel.textColor = .systemGray3
        
        unpaidStackView.addArrangedSubview(unpaidLabel)
        unpaidLabel.snp.makeConstraints {
            $0.width.equalTo(30)
        }
        
        unpaidStackView.addArrangedSubview(self.unpaiedAmountLabel)
        
        self.stackView.addArrangedSubview(paidStackView)
        paidStackView.snp.makeConstraints {
            $0.height.equalTo(24)
        }
        self.stackView.addArrangedSubview(unpaidStackView)
        unpaidStackView.snp.makeConstraints {
            $0.height.equalTo(24)
        }
        
        let divider = UIView()
        divider.backgroundColor = .systemGray
        self.contentView.addSubview(divider)
        divider.snp.makeConstraints {
            $0.top.equalTo(self.stackView.snp.bottom).offset(4)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        self.contentView.addSubview(self.totalLabel)
        self.totalLabel.snp.makeConstraints {
            $0.top.equalTo(divider).offset(4)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview().offset(-4)
        }
    }
    
    func bind(to viewModel: AdjustmentChartCellViewModel) {
        viewModel.name.bind(to: self.nameLabel.rx.text).disposed(by: self.disposeBag)
        viewModel.paid.bind(to: self.paidAmountLabel.rx.text).disposed(by: self.disposeBag)
        viewModel.unpaid.bind(to: self.unpaiedAmountLabel.rx.text).disposed(by: self.disposeBag)
        viewModel.total.bind(to: self.totalLabel.rx.text).disposed(by: self.disposeBag)
        viewModel.total.compactMap { Int($0) }.asDriver(onErrorJustReturn: 0)
            .drive(onNext: {
                if $0 < 0 {
                    self.totalLabel.textColor = .red
                } else if $0 == 0 {
                    self.totalLabel.textColor = .label
                } else {
                    self.totalLabel.textColor = .blue
                }
            })
            .disposed(by: self.disposeBag)
        viewModel.isHighlighted.withUnretained(self)
            .asDriver(onErrorJustReturn: (self, false))
            .drive(onNext: { own, isHighlighted in
                if isHighlighted {
                own.contentView.borderColor = .systemIndigo
                own.contentView.borderWidth = 2
                } else {
                    own.contentView.borderColor = .clear
                    own.contentView.borderWidth = 0
                }
            })
            .disposed(by: self.disposeBag)
    }
}
