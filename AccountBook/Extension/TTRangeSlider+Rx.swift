//
//  TTRangeSlider+Rx.swift
//  AccountBook
//
//  Created by Hoju Choi on 2022/01/17.
//

import Foundation

import RxCocoa
import RxSwift
import TTRangeSlider

extension Reactive where Base: TTRangeSlider {
    var min: ControlProperty<Float> {
        return controlProperty(editingEvents: .valueChanged,
                               getter: { $0.minValue },
                               setter: { $0.minValue = $1 })
    }
    var max: ControlProperty<Float> {
        return controlProperty(editingEvents: .valueChanged,
                               getter: { $0.maxValue },
                               setter: { $0.maxValue = $1 })
    }
}
