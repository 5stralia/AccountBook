//
//  PieChartViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/27.
//

import Foundation

import Charts
import RxRelay
import RxSwift

final class PieChartViewModel: ViewModel {
    
}

extension PieChartViewModel: ViewModelType {
    typealias ProgressData = (isOverIncome: Bool, income: Int, expenditure: Int)
    
    struct Input {
        
    }
    struct Output {
        let items: BehaviorRelay<[PieChartDataEntry]>
        let progress: Observable<ProgressData>
    }
     
    func transform(input: Input) -> Output {
        let entries = [
            PieChartDataEntry(value: 40, label: "#1"),
            PieChartDataEntry(value: 30, label: "#2"),
            PieChartDataEntry(value: 20, label: "#3"),
            PieChartDataEntry(value: 5, label: "#4"),
            PieChartDataEntry(value: 1, label: "#5"),
            PieChartDataEntry(value: 1, label: "#6"),
            PieChartDataEntry(value: 1, label: "#7"),
            PieChartDataEntry(value: 1, label: "#8"),
            PieChartDataEntry(value: 1, label: "#9")
        ]
        let elements = BehaviorRelay<[PieChartDataEntry]>(value: entries)
        
        let income = BehaviorRelay<Int>(value: 100000)
        let expenditure = BehaviorRelay<Int>(value: 1279000)
        
        let progress = BehaviorRelay.combineLatest(income, expenditure) { income, expenditure -> ProgressData in
            let isOverIncome = income > expenditure
            return (isOverIncome: isOverIncome, income: income, expenditure: expenditure)
        }
        
        return Output(items: elements,
                      progress: progress)
    }
}
