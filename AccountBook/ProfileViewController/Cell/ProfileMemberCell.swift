//
//  ProfileMemberCell.swift
//  AccountBook
//
//  Created by Hoju Choi on 2022/02/04.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class ProfileMemberCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        let colors: [UIColor] = [.red, .blue, .black]
        imageView.backgroundColor = colors.randomElement()
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        contentView.clipsToBounds = true
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.borderWidth = 2
        contentView.borderColor = .systemIndigo
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.cornerRadius = contentView.bounds.height / 2
    }
    
    func bind(to viewModel: ProfileMemberCellViewModel) {
        
    }
}
