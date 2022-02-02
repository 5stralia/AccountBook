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
    private let provider: ABProvider
    
    private let date: Observable<Date>
    private let accounts: Observable<[AccountDocumentModel]>
    
    init(provider: ABProvider, date: Observable<Date>, accounts: Observable<[AccountDocumentModel]>) {
        self.provider = provider
        
        self.date = date
        self.accounts = accounts
    }
}

extension MonthlyChartViewModel: ViewModelType {
    struct Input {
        let selectionCategory: BehaviorRelay<String>
    }
    struct Output {
        let items: BehaviorRelay<[MonthlyChartCellViewModel]>
        let categoryItems: [String]
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[MonthlyChartCellViewModel]>(value: [])
        
        Observable.combineLatest(self.accounts,
                                 self.date,
                                 input.selectionCategory) { accounts, date, category -> [MonthlyChartCellViewModel] in
            let startDate = Calendar.current.date(byAdding: .month, value: -2, to: date)!.firstDay()
            let endDate = Calendar.current.date(byAdding: .month, value: 2, to: date)!.lastDay()
            
            let accounts = accounts
                .filter { $0.date >= startDate }
                .filter { $0.date < endDate }
                .filter {
                    guard category != "총합" else { return true }
                    
                    return $0.category == category
                }
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
                    let progress = totalAmount == 0 ? 0 : Float(monthlyTotal) / Float(totalAmount)
                    return MonthlyChartCellViewModel(amount: monthlyTotal.priceString() ?? "0",
                                                     progress: progress,
                                                     month: "\(components.month!)월")
                }
        }
                                 .bind(to: elements)
                                 .disposed(by: self.disposeBag)
        
        let categoryItems: [String] = ["총합"]
        + ((try? self.provider.group.groupDocumentModel.value())?.categorys ?? [])
        + ["취소"]
        
        return Output(items: elements,
                      categoryItems: categoryItems)
    }
}
