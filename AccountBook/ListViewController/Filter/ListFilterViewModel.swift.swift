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
        
        let amount = BehaviorRelay<String>(value: "없음")
        let category = BehaviorRelay<String>(value: "없음")
        let payer = BehaviorRelay<String>(value: "없음")
        let participants = BehaviorRelay<String>(value: "없음")
        
        Observable.combineLatest(
            amount.asObservable(),
            category.asObservable(),
            payer.asObservable(),
            participants.asObservable()) { amount, category, payer, participants -> [AccountDetailSelectionCellViewModel] in
                return [
                    .init(title: "금액", value: amount),
                    .init(title: "카테고리", value: category),
                    .init(title: "결제", value: payer),
                    .init(title: "참여", value: participants)
                ]
            }
            .bind(to: elements)
            .disposed(by: self.disposeBag)
        
        let selectDetail = input.selection
            .flatMap { [weak self] selection -> Observable<AccountDetailSelectingViewModel> in
                guard let self = self else { return .never() }
                
                switch selection.title.value {
                case "금액":
                    let detailSelectingViewModel = AccountDetailSelectingViewModel(provider: self.provider,
                                                                                   isCategory: true,
                                                                                   items: ["0", "10"],
                                                                                   isAllowMultiSelection: false)
                    detailSelectingViewModel.selectedItems.compactMap { $0.first }
                    .subscribe(onNext: { amount.accept($0) })
                    .disposed(by: self.disposeBag)
                    
                    return .just(detailSelectingViewModel)
                case "카테고리":
                    let detailSelectingViewModel = AccountDetailSelectingViewModel(provider: self.provider,
                                                                                   isCategory: true,
                                                                                   items: ["카테1", "카테2"],
                                                                                   isAllowMultiSelection: false)
                    detailSelectingViewModel.selectedItems.compactMap { $0.first }
                    .subscribe(onNext: { category.accept($0) })
                    .disposed(by: self.disposeBag)
                    
                    return .just(detailSelectingViewModel)
                case "결제":
                    let detailSelectingViewModel = AccountDetailSelectingViewModel(provider: self.provider,
                                                                                   isCategory: true,
                                                                                   items: ["결제1", "결제2"],
                                                                                   isAllowMultiSelection: false)
                    detailSelectingViewModel.selectedItems.compactMap { $0.first }
                    .subscribe(onNext: { payer.accept($0) })
                    .disposed(by: self.disposeBag)
                    
                    return .just(detailSelectingViewModel)
                case "참여":
                    let detailSelectingViewModel = AccountDetailSelectingViewModel(provider: self.provider,
                                                                                   isCategory: true,
                                                                                   items: ["참여1", "참여2"],
                                                                                   isAllowMultiSelection: true)
                    detailSelectingViewModel.selectedItems
                        .subscribe(onNext: { participants.accept($0.joined(separator: ", ")) })
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
