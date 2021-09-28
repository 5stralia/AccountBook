//
//  AccountDetailDateCellViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/28.
//

import Foundation

import RxRelay
import RxSwift

final class AccountDetailDateCellViewModel {
    let title = BehaviorRelay<String?>(value: nil)
    let date = BehaviorRelay<Date>(value: Date())
    
    init(title: String, date: Date) {
        self.title.accept(title)
        self.date.accept(date)
    }
}
