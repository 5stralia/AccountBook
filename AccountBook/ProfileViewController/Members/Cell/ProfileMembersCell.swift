//
//  ProfileMembersCell.swift
//  AccountBook
//
//  Created by Hoju Choi on 2022/05/16.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

class ProfileMembersCell: UICollectionViewCell {
    private let roleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        
        return imageView
    }()
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gatiBlue
        
        return imageView
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .medium)
        
        return label
    }()
    
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(roleImageView)
        contentView.addSubview(nameLabel)
        
        profileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.width.equalTo(60)
        }
        
        roleImageView.snp.makeConstraints { make in
            make.width.height.equalTo(25)
            make.top.equalToSuperview()
            make.centerX.equalTo(profileImageView.snp.centerX)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(42)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(profileImageView.snp.centerY)
        }
    }
    
    func bind(to viewModel: ProfileMembersCellViewModel) {
        viewModel.name.asDriver().drive(nameLabel.rx.text).disposed(by: disposeBag)
    }
}
