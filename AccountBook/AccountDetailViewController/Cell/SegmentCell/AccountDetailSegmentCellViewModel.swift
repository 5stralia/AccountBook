//
//  AccountDetailSegmentCellViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/28.
//

import Foundation

import RxRelay
import RxSwift

final class AccountDetailSegmentCellViewModel {
    let selectedIndex = BehaviorRelay<Int>(value: 0)
    
    init(selectedIndex: Int) {
        self.selectedIndex.accept(selectedIndex)
    }
}
