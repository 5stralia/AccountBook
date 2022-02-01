//
//  MonthlyChartViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/28.
//

import Foundation

import RxRelay
import RxSwift

final class MonthlyChartViewModel: ViewModel {
    private let accounts: Observable<[AccountDocumentModel]>
    
    init(accounts: Observable<[AccountDocumentModel]>) {
        self.accounts = accounts
    }
}

extension MonthlyChartViewModel: ViewModelType {
    struct Input {
        
    }
    struct Output {
        let items: BehaviorRelay<[MonthlyChartCellViewModel]>
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[MonthlyChartCellViewModel]>(value: [])
        
        let date = BehaviorRelay<Date>(value: Date())
        
        Observable.combineLatest(self.accounts,
                                 date.asObservable()) { accounts, date -> [MonthlyChartCellViewModel] in
            let startDate = Calendar.current.date(byAdding: .month, value: -2, to: date)!.firstDay()
            let endDate = Calendar.current.date(byAdding: .month, value: 2, to: date)!.lastDay()
            
            let accounts = accounts
                .filter { $0.date >= startDate }
                .filter { $0.date < endDate }
            let totalAmount = accounts.reduce(0, { $0 + $1.amount })
            var groupByMonth = Dictionary(grouping: accounts,
                                          by: { Calendar.current.dateComponents([.year, .month], from: $0.date) })
            [
                Calendar.current.dateComponents([.year, .month],
                                                from: Calendar.current.date(byAdding: .month, value: -2, to: date)!),
                Calendar.current.dateComponents([.year, .month],
                                                from: Calendar.current.date(byAdding: .month, value: -1, to: date)!),
                Calendar.current.dateComponents([.year, .month], from: date),
                Calendar.current.dateComponents([.year, .month],
                                                from: Calendar.current.date(byAdding: .month, value: 1, to: date)!),
                Calendar.current.dateComponents([.year, .month],
                                                from: Calendar.current.date(byAdding: .month, value: 2, to: date)!),
            ]
                .forEach { components in
                    if groupByMonth[components] == nil {
                        groupByMonth[components] = []
                    }
                }
            return groupByMonth.sorted(by: {
                if $0.key.year! == $1.key.year! {
                    return $0.key.month! < $1.key.month!
                } else {
                    return $0.key.year! < $1.key.year!
                }
            })
                .map { components, accounts in
                    let monthlyTotal = accounts.reduce(0, { $0 + $1.amount })
                    let progress = Float(monthlyTotal) / Float(totalAmount)
                    return MonthlyChartCellViewModel(amount: monthlyTotal.priceString() ?? "0",
                                                     progress: progress,
                                                     month: "\(components.month!)월")
                }
        }
                                 .bind(to: elements)
                                 .disposed(by: self.disposeBag)
        
        return Output(items: elements)
    }
}
