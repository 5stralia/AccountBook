//
//  TabBarViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/01.
//

import Foundation

import Firebase
import RxSwift
import RxCocoa

class TabBarViewModel: ViewModel, ViewModelType {
    struct Input {
        let viewWillAppear: Observable<Void>
        let viewWillDisappear: Observable<Void>
    }
    struct Output {
        let presentSignIn: Observable<Void>
        let items: BehaviorRelay<[ViewModel]>
    }
    
    let database: Database
    let user: ABUser
    var viewModels: [ViewModel] = []
    
    var disposeBag = DisposeBag()
    
    init(database: Database, user: ABUser) {
        self.database = database
        self.user = user
        
        super.init()
    }
    
    func transform(input: Input) -> Output {
        let profileViewModel = ProfileViewModel(database: self.database, user: self.user)
        let chartViewModel = ChartViewModel()
        let listViewModel = ListViewModel()
        let settingViewModel = SettingViewModel()
        
        let viewModels: [ViewModel] = [
            profileViewModel,
            chartViewModel,
            listViewModel,
            settingViewModel
        ]
        
        let items = BehaviorRelay<[ViewModel]>(value: viewModels)
        
        let presentSignIn = Observable.combineLatest(input.viewWillAppear,
                                 self.user.uid.asObservable()) { _, uid in
            return uid
        }
        .filter { $0 == nil }
        .map { _ in }
        
        return Output(presentSignIn: presentSignIn,
                      items: items)
    }
}
