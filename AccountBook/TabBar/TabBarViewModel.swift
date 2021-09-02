//
//  TabBarViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/01.
//

import Foundation

import Firebase
import RxSwift
import RxRelay

class TabBarViewModel: ViewModel, ViewModelType {
    struct Input {
        
    }
    struct Output {
        let items: BehaviorRelay<[ViewModel]>
    }
    
    let database: Database
    var viewModels: [ViewModel] = []
    
    func transform(input: Input) -> Output {
        let profileViewModel = ProfileViewModel(database: self.database)
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
        
        
        return Output(items: items)
    }
    
    init(database: Database) {
        self.database = database
        
        super.init()
    }
}
