//
//  AccountDetailRangeCellViewModel.swift
//  AccountBook
//
//  Created by Hoju Choi on 2022/01/05.
//

import Foundation

import RxRelay
import RxSwift

final class AccountDetailRangeCellViewModel<T: Comparable> {
    let min: BehaviorRelay<T>
    let max: BehaviorRelay<T>
    
    let selectedMin: BehaviorRelay<T>
    let selectedMax: BehaviorRelay<T>
    
    
    init(min: T, max: T) {
        self.min = BehaviorRelay(value: min)
        self.max = BehaviorRelay(value: max)
        
        self.selectedMin = BehaviorRelay(value: min)
        self.selectedMax = BehaviorRelay(value: max)
    }
}
