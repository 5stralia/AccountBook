//
//  ListViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import Foundation

import RxRelay
import RxSwift

class ListViewModel: ViewModel, ViewModelType {
    let provider: ABProvider
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let changeMonthly: Observable<Void>
    }
    struct Output {
        let isMonthly: BehaviorRelay<Bool>
        let items: BehaviorRelay<[ListSection]>
    }
    
    init(provider: ABProvider) {
        self.provider = provider
        
        super.init()
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[ListSection]>(value: [])
        
        Observable.combineLatest(input.viewWillAppear,
                                 self.provider.group.accounts.asObservable()) { _, accounts -> [ListSection] in
            var items: [ListSection] = []
            
            let date = Date()
            let amount = (3442500.priceString() ?? "0") + "원"
            items.append(.info(title: "Info", items: [
                .multipleDatePickerItem(viewModel: ListInfoMultipleDatePickerCellViewModel(startDate: date, endDate: date)),
                .summaryItem(viewModel: ListInfoSummaryCellViewModel(amount: amount))
            ]))
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            
            let accountItems = accounts.map { account -> ListSectionItem in
                return .accountItem(viewModel: ListAccountCellViewModel(date: formatter.string(from: account.date),
                                                                        category: account.category,
                                                                        title: account.name,
                                                                        amount: account.amount.priceString() ?? ""))
            }
            
            items.append(.account(title: "Account", items: accountItems))
            
            return items
        }
                                 .bind(to: elements)
                                 .disposed(by: self.disposeBag)
        
        let isMonthly = BehaviorRelay<Bool>(value: false)
        input.changeMonthly
            .subscribe(onNext: {
                isMonthly.accept(!isMonthly.value)
            })
            .disposed(by: self.disposeBag)
        
        return Output(isMonthly: isMonthly, items: elements)
    }
}
