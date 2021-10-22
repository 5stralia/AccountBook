//
//  ListInfoMultipleDatePickerCellViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/10/22.
//

import Foundation

import RxRelay
import RxCocoa

final class ListInfoMultipleDatePickerCellViewModel {
    let startDate = BehaviorRelay<Date?>(value: nil)
    let endDate = BehaviorRelay<Date?>(value: nil)
    
    init(startDate: Date, endDate: Date) {
        self.startDate.accept(startDate)
        self.endDate.accept(endDate)
    }
}
