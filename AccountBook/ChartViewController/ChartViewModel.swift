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
        let tappedPrevButton: Observable<Void>
        let tappedNextButton : Observable<Void>
    }
    struct Output {
        let items: BehaviorRelay<[ChartSubView]>
        let dateString: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[ChartSubView]>(value: [])
        
        let initialToday = Date()
        let today = BehaviorRelay<Date>(value: initialToday)
        
        let dateString = today.map { date -> String in
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY년 MM월"
            
            return formatter.string(from: date)
        }
        
        
        let accounts = today
            .withUnretained(self)
            .flatMap { own, today -> Single<[AccountDocumentModel]> in
                guard let startDate = Calendar.current.date(byAdding: .month, value: -2, to: today)?.firstDay(),
                      let endDate = Calendar.current.date(byAdding: .month, value: 2, to: today)?.lastDay()
                else { return .never() }
                
                return own.provider.requestAccounts(startDate: startDate, endDate: endDate)
            }
        
        let pieChartViewModelElement = BehaviorRelay<PieChartViewModel>(
            value: PieChartViewModel(provider: self.provider,
                                     date: today.asObservable(),
                                     accounts: accounts.asObservable()))
        let monthlyChartViewModelElement = BehaviorRelay<MonthlyChartViewModel>(
            value: MonthlyChartViewModel(date: today.asObservable(),
                                         accounts: accounts.asObservable()))
        let adjustmentChartViewModelElement = BehaviorRelay<AdjustmentChartViewModel>(
            value: AdjustmentChartViewModel(provider: self.provider,
                                            date: today.asObservable(),
                                            accounts: accounts.asObservable()))
        
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
        
        input.tappedPrevButton
            .withLatestFrom(today) { ($0, $1) }
            .compactMap { _, date in
                return Calendar.current.date(byAdding: .month, value: -1, to: date)
            }
            .bind(to: today)
            .disposed(by: self.disposeBag)
        
        input.tappedNextButton
            .withLatestFrom(today) { ($0, $1) }
            .compactMap { _, date in
                return Calendar.current.date(byAdding: .month, value: 1, to: date)
            }
            .bind(to: today)
            .disposed(by: self.disposeBag)
        
        return Output(items: elements,
                      dateString: dateString)
    }
}
