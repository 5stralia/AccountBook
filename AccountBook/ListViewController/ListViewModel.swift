//
//  ListViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import Foundation

import RxRelay
import RxSwift

class ListViewModel: ViewModel, ViewModelType {
    let provider: ABProvider
    
    var cellDisposeBag = DisposeBag()
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let changeMonthly: Observable<Void>
        let selectedDatePickerItem: Observable<(yearIndex: Int, monthIndex: Int)>
        let showFilter: Observable<Void>
    }
    struct Output {
        let isMonthly: BehaviorRelay<Bool>
        let items: BehaviorRelay<[ListSection]>
        let showYearMonthPicker: PublishRelay<Void>
        let yearMonthPickerItems: Observable<[[Int]]>
        let startDate: BehaviorRelay<Date>
        let showFilter: Observable<ListFilterViewModel>
    }
    
    init(provider: ABProvider) {
        self.provider = provider
        
        super.init()
    }
    
    func transform(input: Input) -> Output {
        let isMonthly = BehaviorRelay<Bool>(value: true)
        
        let showYearMonthPicker = PublishRelay<Void>()
        
        let date = Date()
        
        let startDate = BehaviorRelay<Date>(value: date.firstDay())
        let endDate = BehaviorRelay<Date>(value: date.lastDay())
        
        let filterViewModel = ListFilterViewModel(provider: self.provider)
        
        let accounts = BehaviorRelay<[AccountDocumentModel]>(value: [])
        let accountsObservable = accounts.share()
        
        Observable.combineLatest(startDate.asObservable(), endDate.asObservable())
            .flatMapLatest { [weak self] start, end -> Single<[AccountDocumentModel]> in
                guard let self = self else { return .never() }
                return self.provider.requestAccounts(startDate: start, endDate: end)
            }
            .bind(to: accounts)
            .disposed(by: self.disposeBag)
        
        accountsObservable
            .map {
                let amounts = $0.map { $0.amount }
                return (min: amounts.min() ?? 0, max: amounts.max() ?? 1000000000)
            }
            .bind(to: filterViewModel.amountRangeElement)
            .disposed(by: self.disposeBag)
        
        accountsObservable
            .map {
                $0.map { $0.category }.reduce([], { $0.contains($1) ? $0 : $0 + [$1] })
            }
            .bind(to: filterViewModel.categoryElements)
            .disposed(by: self.disposeBag)
        
        self.provider.group.members
            .map { members in members.map { $0.name } }
            .bind(to: filterViewModel.participantElements, filterViewModel.payerElements)
            .disposed(by: self.disposeBag)
        
        let accountElements = Observable.combineLatest(accounts.asObservable(),
                                                       filterViewModel.amountRange.asObservable(),
                                                       filterViewModel.category.asObservable(),
                                                       filterViewModel.payer.asObservable(),
                                                       filterViewModel.participants.asObservable())
        { accounts, amountRange, category, payer, participants -> [AccountDocumentModel] in
            var accounts = accounts
            
            if let (min, max) = amountRange {
                accounts = accounts
                    .filter { $0.amount >= min }
                    .filter { $0.amount <= max }
            }
            
            if let category = category {
                accounts = accounts.filter { $0.category == category }
            }
            
            if let payer = payer {
                accounts = accounts.filter { $0.payer == payer }
            }
            
            if !participants.isEmpty {
                accounts = accounts.filter { account in
                    return participants.reduce(true, { $0 && account.participants.contains($1)})
                }
            }
            
            return accounts
        }
        
        let elements = BehaviorRelay<[ListSection]>(value: [])
        
        Observable.combineLatest(input.viewWillAppear,
                                 isMonthly.asObservable(),
                                 startDate.asObservable(),
                                 endDate.asObservable(),
                                 accountElements) { [weak self] _, isMonthly, startDateValue, endDateValue, accounts -> [ListSection] in
            guard let self = self else { return [] }
            self.cellDisposeBag = DisposeBag()
            
            var items: [ListSection] = []
            
            var infoSectionItems: [ListSectionItem] = []
            
            if isMonthly {
                let datePickerItemViewModel = ListInfoDatePickerCellViewModel(date: startDateValue)
                datePickerItemViewModel.backwardMonth.asObservable()
                    .subscribe(onNext: {
                        startDate.accept(startDateValue.backwardMonth(1).firstDay())
                        endDate.accept(endDateValue.backwardMonth(1).lastDay())
                    })
                    .disposed(by: self.cellDisposeBag)
                datePickerItemViewModel.selectMonth
                    .bind(to: showYearMonthPicker)
                    .disposed(by: self.cellDisposeBag)
                 datePickerItemViewModel.forwardMonth.asObservable()
                    .subscribe(onNext: {
                        startDate.accept(startDateValue.forwardMonth(1).firstDay())
                        endDate.accept(endDateValue.forwardMonth(1).lastDay())
                    })
                    .disposed(by: self.cellDisposeBag)
                
                infoSectionItems.append(.datePickerItem(viewModel: datePickerItemViewModel))
            } else {
                infoSectionItems.append(.multipleDatePickerItem(viewModel: ListInfoMultipleDatePickerCellViewModel(startDate: startDateValue, endDate: endDateValue)))
            }
            
            let amount = (3442500.priceString() ?? "0") + "원"
            infoSectionItems.append(.summaryItem(viewModel: ListInfoSummaryCellViewModel(amount: amount)))
            
            items.append(.info(title: "Info", items: infoSectionItems))
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            
            let accountItems = accounts.map { account -> ListSectionItem in
                return .accountItem(viewModel: ListAccountCellViewModel(date: formatter.string(from: account.date),
                                                                        category: account.category,
                                                                        title: account.name,
                                                                        amount: account.amount.priceString() ?? ""))
            }
            
            items.append(.account(title: "Account", items: accountItems))
            
            return items
        }
                                 .bind(to: elements)
                                 .disposed(by: self.disposeBag)
        
        let years = (2000...Calendar.current.component(.year, from: date)).map { $0 }
        let months = (1...12).map { $0 }
        let yearMonthPickerItems = Observable.just([years, months])
        
        input.changeMonthly
            .subscribe(onNext: {
                isMonthly.accept(!isMonthly.value)
            })
            .disposed(by: self.disposeBag)
        
        input.selectedDatePickerItem
            .map { (years[$0.yearIndex], months[$0.monthIndex]) }
            .map { Calendar.current.date(from: DateComponents(year: $0.0, month: $0.1)) ?? date }
            .bind(to: startDate)
            .disposed(by: self.disposeBag)
        
        let showFilter = input.showFilter.map { filterViewModel }
        
        return Output(isMonthly: isMonthly,
                      items: elements,
                      showYearMonthPicker: showYearMonthPicker,
                      yearMonthPickerItems: yearMonthPickerItems,
                      startDate: startDate,
                      showFilter: showFilter)
    }
}
