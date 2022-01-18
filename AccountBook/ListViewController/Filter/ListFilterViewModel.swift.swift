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
    
    let isAmountASC = BehaviorRelay<Bool>(value: true)
    let amountRange = BehaviorRelay<(min: Int, max: Int)?>(value: nil)
    let category = BehaviorRelay<String?>(value: nil)
    let payer = BehaviorRelay<String?>(value: nil)
    let participants = BehaviorRelay<[String]>(value: [])
    
    let amountElements = BehaviorRelay<[Int]>(value: [])
//    let amountRangeElement =
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
        let selectDetail: Observable<ViewModel>
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[AccountDetailSelectionCellViewModel]>(value: [])
        
        Observable.combineLatest(
            self.isAmountASC.asObservable(),
            self.amountRange.asObservable(),
            self.category.asObservable(),
            self.payer.asObservable(),
            self.participants.asObservable()) { isAmountASC, amountRange, category, payer, participants -> [AccountDetailSelectionCellViewModel] in
                
                let sortValue = isAmountASC ? "오름차순" : "내림차순"
                let amountRangeValue = amountRange != nil
                ? "\(amountRange!.min)~\(amountRange!.max) \(sortValue)"
                : "없음"
                
                let joinedParticipants = participants.joined(separator: ", ")
                let participantsValue = joinedParticipants.isEmpty ? "없음" : joinedParticipants
                
                return [
                    .init(title: "금액", value: amountRangeValue),
                    .init(title: "카테고리", value: category ?? "없음"),
                    .init(title: "결제", value: payer ?? "없음"),
                    .init(title: "참여", value: participantsValue)
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
        { [weak self] (selection, filters) -> Observable<ViewModel> in
                guard let self = self else { return .never() }
                
                switch selection.title.value {
                case "금액":
                    let rangeViewModel = ListFilterRangeItemViewModel(isASC: true, range: (min: 0, max: 100000))
                    return .just(rangeViewModel)
                case "카테고리":
                    let items = ["없음"] + filters.categories
                    let detailSelectingViewModel = AccountDetailSelectingViewModel(provider: self.provider,
                                                                                   isCategory: true,
                                                                                   items: items,
                                                                                   isAllowMultiSelection: false,
                                                                                   isRangeItem: false)
                    detailSelectingViewModel.selectedItems.compactMap { $0.first }
                    .map { $0 == "없음" ? nil : $0 }
                    .bind(to: self.category)
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
                    .map { $0 == "없음" ? nil : $0 }
                    .bind(to: self.payer)
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
                        .bind(to: self.participants)
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
