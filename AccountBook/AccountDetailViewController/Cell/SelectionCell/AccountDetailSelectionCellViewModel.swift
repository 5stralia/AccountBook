//
//  AccountDetailSelectionCellViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/28.
//

import Foundation

import RxRelay
import RxSwift

class AccountDetailSelectionCellViewModel {
    let title = BehaviorRelay<String?>(value: nil)
    let value = BehaviorRelay<String?>(value: nil)
    
    init(title: String, value: String) {
        self.title.accept(title)
        self.value.accept(value)
    }
}
