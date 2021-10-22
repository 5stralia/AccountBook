//
//  DatePickerCellViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/10/20.
//

import Foundation

import RxRelay
import RxSwift

final class ListInfoDatePickerCellViewModel {
    let date = BehaviorRelay<Date?>(value: nil)
    
    init(date: Date) {
        self.date.accept(date)
    }
}
