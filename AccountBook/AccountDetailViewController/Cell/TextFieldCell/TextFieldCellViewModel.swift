//
//  TextFieldCellViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/27.
//

import Foundation

import RxRelay
import RxSwift

final class TextFieldCellViewModel {
    let text = BehaviorRelay<String?>(value: nil)
    
    init(text: String?) {
        self.text.accept(text)
    }
}
