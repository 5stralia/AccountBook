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
    let range: BehaviorRelay<(min: Int, max: Int)>
    
    init(isASC: Bool, range: (min: Int, max: Int)) {
        self.isASC = BehaviorRelay<Bool>(value: isASC)
        self.range = BehaviorRelay<(min: Int, max: Int)>(value: range)
        
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
        let initialMin: Int
        let initialMax: Int
    }
    
    func transform(input: Input) -> Output {
        input.changeToASC.bind(to: self.isASC).disposed(by: self.disposeBag)
        input.changeMin.withLatestFrom(self.range) { changed, range -> (min: Int, max: Int) in
            return (min: changed, max: range.max)
        }
        .bind(to: self.range)
        .disposed(by: self.disposeBag)
        input.changeMax.withLatestFrom(self.range) { changed, range -> (min: Int, max: Int) in
            return (min: range.min, max: changed)
        }
        .bind(to: self.range)
        .disposed(by: self.disposeBag)
        
        return Output(isASC: self.isASC,
                      initialMin: self.range.value.min,
                      initialMax: self.range.value.max)
    }
}
