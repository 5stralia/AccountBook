//
//  AdjustmentChartCellViewModel.swift
//  AccountBook
//
//  Created by Hoju Choi on 2022/01/22.
//

import Foundation

import RxRelay
import RxSwift

final class AdjustmentChartCellViewModel {
    let name: BehaviorRelay<String>
    let paid: BehaviorRelay<String>
    let unpaid: BehaviorRelay<String>
    let total: BehaviorRelay<String>
    let isHighlighted: BehaviorRelay<Bool>
    
    init(name: String, paid: String, unpaid: String, total: String, isHighlighted: Bool) {
        self.name = BehaviorRelay<String>(value: name)
        self.paid = BehaviorRelay<String>(value: paid)
        self.unpaid = BehaviorRelay<String>(value: unpaid)
        self.total = BehaviorRelay<String>(value: total)
        self.isHighlighted = BehaviorRelay<Bool>(value: isHighlighted)
    }
}
