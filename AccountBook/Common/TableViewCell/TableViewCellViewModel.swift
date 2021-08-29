//
//  TableViewCellViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import Foundation

import RxSwift
import RxCocoa

class TableViewCellViewModel {
    let title = BehaviorRelay<String?>(value: nil)
    let detail = BehaviorRelay<String?>(value: nil)
    let isHiddenAccesoryImageView = BehaviorRelay<Bool>(value: true)
    
    init(title: String?, detail: String?, isHiddenAccesoryImageView: Bool) {
        self.title.accept(title)
        self.detail.accept(detail)
        self.isHiddenAccesoryImageView.accept(isHiddenAccesoryImageView)
    }
}
