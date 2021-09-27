//
//  ListAccountCellViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/22.
//

import Foundation

import RxRelay
import RxSwift

final class ListAccountCellViewModel {
    let date = BehaviorRelay<String?>(value: nil)
    let category = BehaviorRelay<String?>(value: nil)
    let title = BehaviorRelay<String?>(value: nil)
    let amount = BehaviorRelay<String?>(value: nil)
    
    init(date: String, category: String, title: String, amount: String) {
        self.date.accept(date)
        self.category.accept(category)
        self.title.accept(title)
        self.amount.accept(amount)
    }
}
