//
//  AccountDetailSelectingViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/30.
//

import Foundation

import RxRelay
import RxSwift

final class AccountDetailSelectingViewModel: ViewModel, ViewModelType {
    struct Input {
        let selection: Observable<AccountDetailSelectingSectionItem>
    }
    struct Output {
        let items: BehaviorRelay<[AccountDetailSelectingSection]>
        let selectedEvent: Observable<AccountDetailSelectingSectionItem>
    }
    
    let items: [String]
    let isCategory: Bool
    let provider: ABProvider
    
    let selectedItem = BehaviorRelay<String?>(value: nil)
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[AccountDetailSelectingSection]>(value: [
            .selecting(title: "선택", items: self.items.map {
                AccountDetailSelectingSectionItem.titleItem(viewModel: AccountDetailSelectingCellViewModel(title: $0))
            })
        ])
        
        let selectedEvent = input.selection
        
        selectedEvent
            .subscribe(onNext: { item in
                switch item {
                case .titleItem(let viewModel):
                    self.selectedItem.accept(viewModel.title.value)
                default:
                    break
                }
            })
            .disposed(by: self.disposeBag)
        
        return Output(items: elements,
                      selectedEvent: selectedEvent)
    }
    
    init(provider: ABProvider, isCategory: Bool, items: [String]) {
        self.provider = provider
        self.isCategory = isCategory
        self.items = items
        super.init()
    }
}
