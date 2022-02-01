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
    let provider: ABProvider
    let accounts: Observable<[AccountDocumentModel]>
    
    init(provider: ABProvider, accounts: Observable<[AccountDocumentModel]>) {
        self.provider = provider
        self.accounts = accounts
    }
}

extension PieChartViewModel: ViewModelType {
    typealias ProgressData = (isOverIncome: Bool, income: Int, expenditure: Int)
    
    struct Input {
        
    }
    struct Output {
        let isPieChart: BehaviorRelay<Bool>
        let pieItems: BehaviorRelay<[PieChartDataEntry]>
        let barItems: BehaviorRelay<[BarChartCellViewModel]>
        let progress: Observable<ProgressData>
    }
     
    func transform(input: Input) -> Output {
        let isPieChart = BehaviorRelay<Bool>(value: true)
        let pieElements = BehaviorRelay<[PieChartDataEntry]>(value: [])
        let barElements = BehaviorRelay<[BarChartCellViewModel]>(value: [])
        
        let date = BehaviorRelay<Date>(value: Date())
        
        let currentAccounts = Observable.combineLatest(self.accounts,
                                 date.asObservable())
        { accounts, date -> [AccountDocumentModel] in
            let startDate = date.firstDay()
            let endDate = date.lastDay()
            
            return accounts
                .filter { $0.date >= startDate }
                .filter { $0.date <= endDate}
            
        }
        .share()
        
        currentAccounts
            .map { accounts -> [PieChartDataEntry] in
                let groupBying = Dictionary(grouping: accounts, by: { $0.category })
                return groupBying.map { (category, accounts) in
                    let value = accounts.reduce(0, { $0 + $1.amount })
                    return PieChartDataEntry(value: Double(value), label: category)
                }
            }
            .bind(to: pieElements)
            .disposed(by: self.disposeBag)
        
        let income = currentAccounts
            .map { $0.filter { $0.amount >= 0 } }
            .map { $0.reduce(0, { $0 + $1.amount} ) }
        let expenditure = currentAccounts
            .map { $0.filter { $0.amount < 0 } }
            .map { $0.reduce(0, { $0 + $1.amount} ) }
        
        let progress = BehaviorRelay.combineLatest(income, expenditure) { income, expenditure -> ProgressData in
            let isOverIncome = income > expenditure
            return (isOverIncome: isOverIncome, income: income, expenditure: expenditure)
        }
        
        return Output(isPieChart: isPieChart,
                      pieItems: pieElements,
                      barItems: barElements,
                      progress: progress)
    }
}
