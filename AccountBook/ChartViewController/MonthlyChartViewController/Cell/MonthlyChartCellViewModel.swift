//
//  MonthlyChartCellViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import Foundation

import RxRelay
import RxSwift

class MonthlyChartCellViewModel {
    let amount = BehaviorRelay<String?>(value: nil)
    let progress = BehaviorRelay<Float>(value: 0.0)
    let month = BehaviorRelay<String?>(value: nil)
    
    init(amount: String, progress: Float, month: String) {
        self.amount.accept(amount)
        self.progress.accept(progress)
        self.month.accept(month)
    }
}
