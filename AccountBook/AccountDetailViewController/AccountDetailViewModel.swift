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
        let viewWillAppear: Observable<Void>
        let selection: Observable<AccountDetailSectionItem>
    }
    struct Output {
        let items: BehaviorRelay<[AccountDetailSection]>
        let selectSubItem: BehaviorRelay<AccountDetailSelectingViewModel?>
    }
    
    let provider: ABProvider
    
    var disposeBag = DisposeBag()
    
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
        
        let category = BehaviorRelay<String?>(value: nil)
        
        Observable.combineLatest(input.viewWillAppear, category.asObservable()) { _, category -> [AccountDetailSection] in
            var items = [AccountDetailSection]()
            
            items.append(
                .main(title: "main", items: [
                    .titleItem(viewModel: TextFieldCellViewModel(text: "", placeholderText: "어디에 사용하셨나요?")),
                    .amountItem(viewModel: TextFieldCellViewModel(text: "", placeholderText: "0"))
                ]))
            
            items.append(
                .sub(title: "sub", items: [
                    .categoryItem(viewModel: AccountDetailSelectionCellViewModel(title: "category", value: category ?? "")),
                    .payerItem(viewModel: AccountDetailSelectionCellViewModel(title: "payer", value: "")),
                    .participantItem(viewModel: AccountDetailSelectionCellViewModel(title: "attendant", value: "")),
                    .dateItem(viewModel: AccountDetailDateCellViewModel(title: "date", date: Date())),
                    .segmentItem(viewModel: AccountDetailSegmentCellViewModel(selectedIndex: 0))
                ]))
            
            return items
        }
        .bind(to: elements)
        .disposed(by: self.disposeBag)
        
        let selectSubItem = BehaviorRelay<AccountDetailSelectingViewModel?>(value: nil)
        
        input.selection
            .subscribe(onNext: { item in
                switch item {
                case .categoryItem(let viewModel),
                        .payerItem(let viewModel),
                        .participantItem(let viewModel):
                    let items = (try? self.provider.group.groupDocumentModel.value()?.categorys) ?? []
                    let selectingViewModel = AccountDetailSelectingViewModel(provider: self.provider, isCategory: true, items: items)
                    selectingViewModel.selectedItem.bind(to: category).disposed(by: self.disposeBag)
                    selectSubItem.accept(selectingViewModel)
                default:
                    break
                }
            })
            .disposed(by: self.disposeBag)
        
        return Output(items: elements,
                      selectSubItem: selectSubItem)
    }
    
    init(provider: ABProvider) {
        self.provider = provider
        super.init()
    }
    
}
