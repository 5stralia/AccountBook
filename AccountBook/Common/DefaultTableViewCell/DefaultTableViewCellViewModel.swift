//
//  DefaultTableViewCellViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/30.
//

import Foundation

import RxRelay
import RxSwift

final class DefaultTableViewCellViewModel {
    let title = BehaviorRelay<String?>(value: nil)
    
    init(title: String) {
        self.title.accept(title)
    }
}
