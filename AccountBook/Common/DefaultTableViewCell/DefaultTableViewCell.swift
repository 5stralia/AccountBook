//
//  DefaultTableViewCell.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/30.
//

import UIKit

import RxCocoa
import RxSwift

class DefaultTableViewCell: UITableViewCell {

    func bind(to viewModel: DefaultTableViewCellViewModel) {
        viewModel.title.bind(to: self.)
    }
}
