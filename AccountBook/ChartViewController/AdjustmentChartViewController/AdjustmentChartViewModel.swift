//
//  AdjustmentChartViewModel.swift
//  AccountBook
//
//  Created by Hoju Choi on 2022/01/22.
//

import Foundation

import RxRelay
import RxSwift

final class AdjustmentChartViewModel: ViewModel {
    let provider: ABProvider
    private let accounts: Observable<[AccountDocumentModel]>
    
    init(provider: ABProvider, accounts: Observable<[AccountDocumentModel]>) {
        self.provider = provider
        self.accounts = accounts
    }
}

extension AdjustmentChartViewModel: ViewModelType {
    struct Input {
        
    }
    struct Output {
        let items: BehaviorRelay<[AdjustmentChartCellViewModel]>
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[AdjustmentChartCellViewModel]>(value: [])
        
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
        
        Observable.combineLatest(currentAccounts,
                                 self.provider.group.members.asObservable())
        { accounts, members -> [AdjustmentChartCellViewModel] in
            let payer = Dictionary(grouping: accounts, by: { $0.payer })
                .mapValues { $0.reduce(0, { $0 + $1.amount }) }
            let participantTuple = Dictionary(members.map { ($0.uid, 0) },
                                         uniquingKeysWith: { (first, _) in first })
                .map { key, _ in
                    return (key,
                            accounts.reduce(0, {
                        $0 + ($1.participants.contains(key) ? ($1.amount / $1.participants.count) : 0)
                    }))
                }
            let participant = Dictionary(uniqueKeysWithValues: participantTuple)
            
            return members.map {
                let paid = payer[$0.uid] ?? 0
                let unpaid = participant[$0.uid] ?? 0
                let isHighlighted = (try? self.provider.user.value())?.uid == $0.uid
                
                return AdjustmentChartCellViewModel(name: $0.name,
                                                    paid: paid.priceString() ?? "0",
                                                    unpaid: unpaid.priceString() ?? "0",
                                                    total: (unpaid - paid).priceString() ?? "0",
                                                    isHighlighted: isHighlighted)
            }
        }
        .bind(to: elements)
        .disposed(by: self.disposeBag)
        
        return Output(items: elements)
    }
}
