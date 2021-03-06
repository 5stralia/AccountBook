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
    let placeholderText = BehaviorRelay<String?>(value: nil)
    
    init(text: String, placeholderText: String) {
        self.text.accept(text)
        self.placeholderText.accept(placeholderText)
    }
}
