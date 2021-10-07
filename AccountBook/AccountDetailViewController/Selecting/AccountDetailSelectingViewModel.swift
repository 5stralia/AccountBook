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
        let deSelection: Observable<AccountDetailSelectingSectionItem>
    }
    struct Output {
        let items: BehaviorRelay<[AccountDetailSelectingSection]>
    }
    
    let items: [String]
    let isCategory: Bool
    let provider: ABProvider
    
    let selectedItems = BehaviorRelay<[String]>(value: [])
    
    let isAllowMultiSelection = BehaviorRelay<Bool>(value: false)
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[AccountDetailSelectingSection]>(value: [
            .selecting(title: "선택", items: self.items.map {
                AccountDetailSelectingSectionItem.titleItem(viewModel: AccountDetailSelectingCellViewModel(title: $0))
            })
        ])
        
        input.selection
            .subscribe(onNext: { item in
                switch item {
                case .titleItem(let viewModel):
                    self.selectedItems.accept((self.selectedItems.value) + [viewModel.title.value ?? ""])
                default:
                    break
                }
            })
            .disposed(by: self.disposeBag)
        
        input.deSelection
            .subscribe(onNext: { item in
                switch item {
                case .titleItem(let viewModel):
                    self.selectedItems.accept((self.selectedItems.value.filter { $0 != (viewModel.title.value ?? "") }))
                default:
                    break
                }
            })
            .disposed(by: self.disposeBag)
        
        return Output(items: elements)
    }
    
    init(provider: ABProvider, isCategory: Bool, items: [String], isAllowMultiSelection: Bool) {
        self.provider = provider
        self.isCategory = isCategory
        self.items = items
        self.isAllowMultiSelection.accept(isAllowMultiSelection)
        
        super.init()
    }
}
