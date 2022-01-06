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
        let popViewController: Observable<Void>
    }
    
    let items: [String]
    let isCategory: Bool
    let provider: ABProvider
    
    let selectedItems = BehaviorRelay<[String]>(value: [])
    
    let isAllowMultiSelection = BehaviorRelay<Bool>(value: false)
    let isRangeItem: Bool
    
    func transform(input: Input) -> Output {
        let initialItems: [AccountDetailSelectingSectionItem] = self.isRangeItem
        ? [.rangeItem(viewModel: AccountDetailRangeCellViewModel<Int>(
            min: self.items.compactMap { Int($0) }.min() ?? 0,
            max: self.items.compactMap { Int($0) }.max() ?? 0
        ))]
        : self.items.map {
                .titleItem(viewModel: AccountDetailSelectingCellViewModel(title: $0))
            }
        let elements = BehaviorRelay<[AccountDetailSelectingSection]>(value: [
            .selecting(title: "선택", items: initialItems)
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
        
        let popViewController = input.selection.flatMap { _ -> Observable<Void> in
            if self.isAllowMultiSelection.value {
                return .never()
            } else {
                return .just(())
            }
        }
        
        return Output(items: elements,
                      popViewController: popViewController)
    }
    
    init(provider: ABProvider, isCategory: Bool, items: [String], isAllowMultiSelection: Bool, isRangeItem: Bool) {
        self.provider = provider
        self.isCategory = isCategory
        self.items = items
        self.isAllowMultiSelection.accept(isAllowMultiSelection)
        
        self.isRangeItem = isRangeItem
        
        super.init()
    }
}
