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
    }
    struct Output {
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
            
            items.append(.info(title: "Info", items: [.infoItem(viewModel: ListInfoCellViewModel())]))
            
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
        
        
        return Output(items: elements)
    }
}
