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
    private let provider: ABProvider
    
    private let date: Observable<Date>
    private let accounts: Observable<[AccountDocumentModel]>
    
    init(provider: ABProvider, date: Observable<Date>, accounts: Observable<[AccountDocumentModel]>) {
        self.provider = provider
        
        self.date = date
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
        
        let currentAccounts = Observable.combineLatest(self.accounts,
                                                       self.date)
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
                let expenditures = accounts.filter { $0.amount >= 0 }
                let groupBying = Dictionary(grouping: expenditures, by: { $0.category })
                let totalValue = expenditures.reduce(0, { $0 + $1.amount })
                return groupBying.map { (category, accounts) in
                    let value = accounts.reduce(0, { $0 + $1.amount })
                    return PieChartDataEntry(value: Double(value) / Double(totalValue) * 100, label: category)
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
