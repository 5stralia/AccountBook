//
//  ListFilterRangeItemViewModel.swift
//  AccountBook
//
//  Created by Hoju Choi on 2022/01/07.
//

import Foundation

import RxRelay
import RxSwift

final class ListFilterRangeItemViewModel: ViewModel {
    let isASC: BehaviorRelay<Bool>
    let selectedRange: BehaviorRelay<(min: Int, max: Int)>
    
    let range: (min: Int, max: Int)
    
    init(isASC: Bool, selectedRange: (min: Int, max: Int), range: (min: Int, max: Int)) {
        self.isASC = BehaviorRelay<Bool>(value: isASC)
        self.selectedRange = BehaviorRelay<(min: Int, max: Int)>(value: selectedRange)
        
        self.range = range
        
        super.init()
    }
}

extension ListFilterRangeItemViewModel: ViewModelType {
    struct Input {
        let changeToASC: Observable<Bool>
        let changeMin: Observable<Int>
        let changeMax: Observable<Int>
    }
    struct Output {
        let isASC: BehaviorRelay<Bool>
        let min: Int
        let max: Int
        let initialSelectedMin: Int
        let initialSelectedMax: Int
    }
    
    func transform(input: Input) -> Output {
        input.changeToASC.bind(to: self.isASC).disposed(by: self.disposeBag)
        input.changeMin.withLatestFrom(self.selectedRange) { changed, range -> (min: Int, max: Int) in
            return (min: changed, max: range.max)
        }
        .bind(to: self.selectedRange)
        .disposed(by: self.disposeBag)
        input.changeMax.withLatestFrom(self.selectedRange) { changed, range -> (min: Int, max: Int) in
            return (min: range.min, max: changed)
        }
        .bind(to: self.selectedRange)
        .disposed(by: self.disposeBag)
        
        return Output(isASC: self.isASC,
                      min: self.range.min,
                      max: self.range.max,
                      initialSelectedMin: self.selectedRange.value.min,
                      initialSelectedMax: self.selectedRange.value.max)
    }
}
