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
    case monthly(viewModel: MonthlyChartViewModel)
    case adjustment(viewModel: AdjustmentChartViewModel)
    
    var viewModel: ViewModel {
        switch self {
        case .pie(let viewModel): return viewModel
        case .monthly(let viewModel): return viewModel
        case .adjustment(let viewModel): return viewModel
        }
    }
}

class ChartViewModel: ViewModel {
    let provider: ABProvider
    
    init(provider: ABProvider) {
        self.provider = provider
    }
}

extension ChartViewModel: ViewModelType {
    struct Input {
        
    }
    struct Output {
        let items: BehaviorRelay<[ChartSubView]>
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[ChartSubView]>(value: [])
        
        let initialToday = Date()
        let today = BehaviorRelay<Date>(value: initialToday)
        
        let accounts = today
            .withUnretained(self)
            .flatMap { own, today -> Single<[AccountDocumentModel]> in
                guard let startDate = Calendar.current.date(byAdding: .month, value: -2, to: today)?.firstDay(),
                      let endDate = Calendar.current.date(byAdding: .month, value: 2, to: today)?.lastDay()
                else { return .never() }
                
                return own.provider.requestAccounts(startDate: startDate, endDate: endDate)
            }
        
        let pieChartViewModelElement = BehaviorRelay<PieChartViewModel>(
            value: PieChartViewModel(provider: self.provider, accounts: accounts.asObservable()))
        let monthlyChartViewModelElement = BehaviorRelay<MonthlyChartViewModel>(
            value: MonthlyChartViewModel(accounts: accounts.asObservable()))
        let adjustmentChartViewModelElement = BehaviorRelay<AdjustmentChartViewModel>(
            value: AdjustmentChartViewModel(provider: self.provider, accounts: accounts.asObservable()))
        
        Observable.combineLatest(pieChartViewModelElement.asObservable(),
                                 monthlyChartViewModelElement.asObservable(),
                                 adjustmentChartViewModelElement.asObservable())
        { pieChartViewModel, monthlyChartViewModel, adjustmentChartViewModel -> [ChartSubView] in
            
            return [
                .pie(viewModel: pieChartViewModel),
                .monthly(viewModel: monthlyChartViewModel),
                .adjustment(viewModel: adjustmentChartViewModel)
            ]
        }
        .bind(to: elements)
        .disposed(by: self.disposeBag)
        
        return Output(items: elements)
    }
}
