//
//  BarChartCellViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/28.
//

import Foundation

import RxRelay
import RxSwift

final class BarChartCellViewModel {
    let title = BehaviorRelay<String?>(value: nil)
    let progress = BehaviorRelay<Float>(value: 0.0)
    let amount = BehaviorRelay<String?>(value: nil)
    
    init(title: String, progress: Float, amount: String) {
        self.title.accept(title)
        self.progress.accept(progress)
        self.amount.accept(amount)
    }
}
