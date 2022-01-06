//
//  AccountDetailSelectingCellViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/30.
//

import Foundation

import RxRelay
import RxSwift

final class AccountDetailSelectingCellViewModel {
    let title = BehaviorRelay<String?>(value: nil)
    let isHiddenChevron = BehaviorRelay<Bool>(value: true)
    
    init(title: String, isHiddenChevron: Bool = true) {
        self.title.accept(title)
        self.isHiddenChevron.accept(isHiddenChevron)
    }
}
