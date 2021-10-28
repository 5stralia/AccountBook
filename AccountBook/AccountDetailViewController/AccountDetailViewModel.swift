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
        let submit: Observable<Void>
    }
    struct Output {
        let items: BehaviorRelay<[AccountDetailSection]>
        let selectSubItem: BehaviorRelay<AccountDetailSelectingViewModel?>
        let isEnabledDoneButton: BehaviorRelay<Bool>
        let dismiss: Observable<Void>
    }
    
    let provider: ABProvider
    
    func transform(input: Input) -> Output {
        let title = BehaviorRelay<String?>(value: nil)
        let amount = BehaviorRelay<Int>(value: 0)
        let category = BehaviorRelay<String?>(value: nil)
        let payer = BehaviorRelay<MemberDocumentModel?>(value: nil)
        let participants = BehaviorRelay<[MemberDocumentModel]>(value: [])
        let date = BehaviorRelay<Date>(value: Date())
        let isExpenditure = BehaviorRelay<Bool>(value: true)
        
        let dismiss = input.submit
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .never() }
                
                let amount = isExpenditure.value ? amount.value : -amount.value
                
                return self.provider.append(account: AccountDocumentModel(date: date.value,
                                                                          name: title.value!,
                                                                          amount: amount,
                                                                          category: category.value!,
                                                                          payer: payer.value!.uid,
                                                                          participants: participants.value.map({ $0.uid })))
                    .andThen(.just(()))
            }
        
        let elements = BehaviorRelay<[AccountDetailSection]>(value: [])
        
        let titleCellViewModel = TextFieldCellViewModel(text: "", placeholderText: "어디에 사용하셨나요?")
        titleCellViewModel.text.bind(to: title).disposed(by: self.disposeBag)
        
        let amountCellViewModel = TextFieldCellViewModel(text: "", placeholderText: "0")
        amountCellViewModel.text.compactMap { Int($0 ?? "0") }.bind(to: amount).disposed(by: self.disposeBag)
        
        Observable.combineLatest(input.viewWillAppear,
                                 category.asObservable(),
                                 payer.asObservable(),
                                 participants.asObservable()) { _, category, payer, participants -> [AccountDetailSection] in
            var items = [AccountDetailSection]()
            
            items.append(
                .main(title: "main", items: [
                    .titleItem(viewModel: titleCellViewModel),
                    .amountItem(viewModel: amountCellViewModel)
                ]))
            
            let dateCellViewModel = AccountDetailDateCellViewModel(title: "Date", date: date.value)
            dateCellViewModel.date.bind(to: date).disposed(by: self.disposeBag)
            
            let segmentCellViewModel = AccountDetailSegmentCellViewModel(selectedIndex: isExpenditure.value ? 0 : 1)
            segmentCellViewModel.selectedIndex
                .flatMap { $0 == 0 ? Observable.just(true) : Observable.just(false) }
                .bind(to: isExpenditure)
                .disposed(by: self.disposeBag)
            
            items.append(
                .sub(title: "sub", items: [
                    .categoryItem(viewModel: AccountDetailSelectionCellViewModel(title: "category", value: category ?? "")),
                    .payerItem(viewModel: AccountDetailSelectionCellViewModel(title: "payer", value: payer?.name ?? "")),
                    .participantItem(viewModel: AccountDetailSelectionCellViewModel(title: "participants", value: participants.map({ $0.name }).joined(separator: ", "))),
                    .dateItem(viewModel: dateCellViewModel),
                    .segmentItem(viewModel: segmentCellViewModel)
                ]))
            
            return items
        }
        .bind(to: elements)
        .disposed(by: self.disposeBag)
        
        let selectSubItem = BehaviorRelay<AccountDetailSelectingViewModel?>(value: nil)
        
        input.selection
            .subscribe(onNext: { item in
                switch item {
                case .categoryItem(let viewModel):
                    let items = (try? self.provider.group.groupDocumentModel.value()?.categorys) ?? []
                    let selectingViewModel = AccountDetailSelectingViewModel(provider: self.provider,
                                                                             isCategory: true,
                                                                             items: items,
                                                                             isAllowMultiSelection: false)
                    selectingViewModel.selectedItems.compactMap { $0.first }.bind(to: category).disposed(by: self.disposeBag)
                    selectSubItem.accept(selectingViewModel)
                case .payerItem(let viewModel):
                    let items = (try? self.provider.group.members.value().map { $0.name }) ?? []
                    let selectingViewModel = AccountDetailSelectingViewModel(provider: self.provider,
                                                                             isCategory: true,
                                                                             items: items,
                                                                             isAllowMultiSelection: false)
                    selectingViewModel.selectedItems.compactMap {
                        $0.first
                    }
                    .compactMap { name in
                        try? self.provider.group.members.value().filter({ memeber in
                            memeber.name == name
                        })
                        .first
                    }
                    .bind(to: payer)
                    .disposed(by: self.disposeBag)
                    
                    selectSubItem.accept(selectingViewModel)
                case .participantItem(let viewModel):
                    let items = (try? self.provider.group.members.value().map { $0.name }) ?? []
                    let selectingViewModel = AccountDetailSelectingViewModel(provider: self.provider,
                                                                             isCategory: true,
                                                                             items: items,
                                                                             isAllowMultiSelection: true)
                    selectingViewModel.selectedItems
                        .map { names in
                            names.compactMap({ name in
                                try? self.provider.group.members.value().filter({ memeber in
                                    memeber.name == name
                                })
                                    .first
                            })
                        }
                        .bind(to: participants)
                        .disposed(by: self.disposeBag)
                    
                    selectSubItem.accept(selectingViewModel)
                default:
                    break
                }
            })
            .disposed(by: self.disposeBag)
        
        let isEnabledDoneButton = BehaviorRelay<Bool>(value: false)
        
        Observable.combineLatest(title.asObservable(),
                                 amount.asObservable(),
                                 category.asObservable(),
                                 payer.asObservable(),
                                 participants.asObservable()) { title, amount, category, payer, participants -> Bool in
            return title != nil && amount > 0 && category != nil && payer != nil && !participants.isEmpty
        }
                                 .bind(to: isEnabledDoneButton)
                                 .disposed(by: self.disposeBag)
        
        return Output(items: elements,
                      selectSubItem: selectSubItem,
                      isEnabledDoneButton: isEnabledDoneButton,
                      dismiss: dismiss)
    }
    
    init(provider: ABProvider) {
        self.provider = provider
        super.init()
    }
    
}
