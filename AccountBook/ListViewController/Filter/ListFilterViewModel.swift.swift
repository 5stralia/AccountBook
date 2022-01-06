//
//  ListFilterViewModel.swift.swift
//  AccountBook
//
//  Created by 최호주 on 2021/10/28.
//

import Foundation

import RxRelay
import RxSwift

final class ListFilterViewModel: ViewModel {
    let provider: ABProvider
    
    let amount = BehaviorRelay<String>(value: "없음")
    let category = BehaviorRelay<String>(value: "없음")
    let payer = BehaviorRelay<String>(value: "없음")
    let participants = BehaviorRelay<String>(value: "없음")
    
    let amountElements = BehaviorRelay<[Int]>(value: [])
    let categoryElements = BehaviorRelay<[String]>(value: [])
    let payerElements = BehaviorRelay<[String]>(value: [])
    let participantElements = BehaviorRelay<[String]>(value: [])
    
    init(provider: ABProvider) {
        self.provider = provider
    }
}

extension ListFilterViewModel: ViewModelType {
    struct Input {
        let selection: Observable<AccountDetailSelectionCellViewModel>
    }
    struct Output {
        let items: BehaviorRelay<[AccountDetailSelectionCellViewModel]>
        let selectDetail: Observable<AccountDetailSelectingViewModel>
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[AccountDetailSelectionCellViewModel]>(value: [])
        
        Observable.combineLatest(
            self.amount.asObservable(),
            self.category.asObservable(),
            self.payer.asObservable(),
            self.participants.asObservable()) { amount, category, payer, participants -> [AccountDetailSelectionCellViewModel] in
                return [
                    .init(title: "금액", value: amount),
                    .init(title: "카테고리", value: category),
                    .init(title: "결제", value: payer),
                    .init(title: "참여", value: participants)
                ]
            }
            .bind(to: elements)
            .disposed(by: self.disposeBag)
        
        let filterElements = BehaviorRelay.combineLatest(self.amountElements,
                                                         self.categoryElements,
                                                         self.payerElements,
                                                         self.participantElements)
        { amounts, categories, payers, participants in
            return (amounts: amounts, categories: categories, payers: payers, participants: participants)
        }
        let selectDetail = input.selection
            .withLatestFrom(filterElements) { ($0, $1) }
            .flatMap
        { [weak self] (selection, filters) -> Observable<AccountDetailSelectingViewModel> in
                guard let self = self else { return .never() }
                
                switch selection.title.value {
                case "금액":
                    let items = ["없음"] + filters.amounts.map { String($0) }
                    let detailSelectingViewModel = AccountDetailSelectingViewModel(provider: self.provider,
                                                                                   isCategory: true,
                                                                                   items: items,
                                                                                   isAllowMultiSelection: false,
                                                                                   isRangeItem: true)
                    detailSelectingViewModel.selectedItems.compactMap { $0.first }
                    .subscribe(onNext: { self.amount.accept($0) })
                    .disposed(by: self.disposeBag)
                    
                    return .just(detailSelectingViewModel)
                case "카테고리":
                    let items = ["없음"] + filters.categories
                    let detailSelectingViewModel = AccountDetailSelectingViewModel(provider: self.provider,
                                                                                   isCategory: true,
                                                                                   items: items,
                                                                                   isAllowMultiSelection: false,
                                                                                   isRangeItem: false)
                    detailSelectingViewModel.selectedItems.compactMap { $0.first }
                    .subscribe(onNext: { self.category.accept($0) })
                    .disposed(by: self.disposeBag)
                    
                    return .just(detailSelectingViewModel)
                case "결제":
                    let items = ["없음"] + filters.payers
                    let detailSelectingViewModel = AccountDetailSelectingViewModel(provider: self.provider,
                                                                                   isCategory: true,
                                                                                   items: items,
                                                                                   isAllowMultiSelection: false,
                                                                                   isRangeItem: false)
                    detailSelectingViewModel.selectedItems.compactMap { $0.first }
                    .subscribe(onNext: { self.payer.accept($0) })
                    .disposed(by: self.disposeBag)
                    
                    return .just(detailSelectingViewModel)
                case "참여":
                    let items = ["없음"] + filters.participants
                    let detailSelectingViewModel = AccountDetailSelectingViewModel(provider: self.provider,
                                                                                   isCategory: true,
                                                                                   items: items,
                                                                                   isAllowMultiSelection: true,
                                                                                   isRangeItem: false)
                    detailSelectingViewModel.selectedItems
                        .subscribe(onNext: { self.participants.accept($0.joined(separator: ",")) })
                    .disposed(by: self.disposeBag)
                    
                    return .just(detailSelectingViewModel)
                default:
                    return .never()
                }
            }
        
        return Output(items: elements,
                      selectDetail: selectDetail.asObservable())
    }
}
