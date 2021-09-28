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
        
    }
    struct Output {
        let items: BehaviorRelay<[AccountDetailSection]>
    }
    
    func transform(input: Input) -> Output {
//        let elements = BehaviorRelay<[AccountDetailSection]>(value: [])
        let elements = BehaviorRelay<[AccountDetailSection]>(value: [
            .main(title: "main", items: [
                .textfieldItem(viewModel: TextFieldCellViewModel(text: "title")),
                .textfieldItem(viewModel: TextFieldCellViewModel(text: "amount"))
            ]),
            .sub(title: "sub", items: [
                .selectionItem(viewModel: AccountDetailSelectionCellViewModel(title: "category", value: "")),
                .selectionItem(viewModel: AccountDetailSelectionCellViewModel(title: "payer", value: "")),
                .multiSelectionItem(viewModel: AccountDetailSelectionCellViewModel(title: "attendant", value: "")),
                .dateItem(viewModel: AccountDetailDateCellViewModel(title: "date", date: Date())),
                .segmentItem(viewModel: AccountDetailSegmentCellViewModel(selectedIndex: 0))
            ])
        ])
        
        
        
        return Output(items: elements)
    }
}
