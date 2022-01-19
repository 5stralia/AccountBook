//
//  ChartViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/26.
//

import Foundation

import RxRelay
import RxSwift

enum ChartSubView {
    case pie(viewModel: PieChartViewModel)
    case bar(viewModel: BarChartViewModel)
    case monthly(viewModel: MonthlyChartViewModel)
    
    var viewModel: ViewModel {
        switch self {
        case .pie(let viewModel): return viewModel
        case .bar(let viewModel): return viewModel
        case .monthly(let viewModel): return viewModel
        }
    }
}

class ChartViewModel: ViewModel {
    
}

extension ChartViewModel: ViewModelType {
    struct Input {
        
    }
    struct Output {
        let items: BehaviorRelay<[ChartSubView]>
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[ChartSubView]>(value: [
            .pie(viewModel: PieChartViewModel()),
            .bar(viewModel: BarChartViewModel()),
            .monthly(viewModel: MonthlyChartViewModel())
        ])
        
        return Output(items: elements)
    }
}
