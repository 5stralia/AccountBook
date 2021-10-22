//
//  SummaryCellViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/10/20.
//

import Foundation

import RxRelay
import RxSwift

final class ListInfoSummaryCellViewModel {
    let amount = BehaviorRelay<String?>(value: nil)
    
    init(amount: String) {
        self.amount.accept(amount)
    }
}
