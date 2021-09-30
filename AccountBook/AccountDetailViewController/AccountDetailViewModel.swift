//
//  AccountDetailViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/27.
//

import Foundation

import RxRelay
import RxSwift

final class AccountDetailViewModel: ViewModel, ViewModelType {
    struct Input {
//        let selection: Observable<AccountDetailSectionItem>
    }
    struct Output {
        let items: BehaviorRelay<[AccountDetailSection]>
    }
    
    let provider: ABProvider
    
    func transform(input: Input) -> Output {
//        let elements = BehaviorRelay<[AccountDetailSection]>(value: [])
        let elements = BehaviorRelay<[AccountDetailSection]>(value: [
            .main(title: "main", items: [
                .titleItem(viewModel: TextFieldCellViewModel(text: "", placeholderText: "어디에 사용하셨나요?")),
                .amountItem(viewModel: TextFieldCellViewModel(text: "", placeholderText: "0"))
            ]),
            .sub(title: "sub", items: [
                .categoryItem(viewModel: AccountDetailSelectionCellViewModel(title: "category", value: "")),
                .payerItem(viewModel: AccountDetailSelectionCellViewModel(title: "payer", value: "")),
                .participantItem(viewModel: AccountDetailSelectionCellViewModel(title: "attendant", value: "")),
                .dateItem(viewModel: AccountDetailDateCellViewModel(title: "date", date: Date())),
                .segmentItem(viewModel: AccountDetailSegmentCellViewModel(selectedIndex: 0))
            ])
        ])
        
        return Output(items: elements)
    }
    
    init(provider: ABProvider) {
        self.provider = provider
        super.init()
    }
    
    func viewModel(_ item: AccountDetailSectionItem) -> ViewModel {
        switch item {
        case .categoryItem(let viewModel):
            let items = (try? self.provider.group.groupDocumentModel.value()?.categorys) ?? []
            return AccountDetailSelectingViewModel(provider: self.provider, isCategory: true, items: items)
        default:
            return AccountDetailSelectingViewModel(provider: self.provider, isCategory: false, items: [])
        }
    }
}
