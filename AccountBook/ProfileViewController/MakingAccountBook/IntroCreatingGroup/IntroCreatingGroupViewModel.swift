//
//  IntroCreatingGroupViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/05.
//

import Foundation

import RxSwift
import RxCocoa

class IntroCreatingGroupViewModel: ViewModel, ViewModelType {
    struct Input {
        let tappedStartButton: Driver<Void>
    }
    struct Output {
        let presentEdittingGroup: Driver<EdittingGroupViewModel>
    }
    
    let database: Database
    let user: ABUser
    
    init(database: Database, user: ABUser) {
        self.database = database
        self.user = user
        
        super.init()
    }
    
    func transform(input: Input) -> Output {
        let database = self.database
        let user = self.user
        
        let presentEdittingGroup = input.tappedStartButton.flatMap { _ -> Driver<EdittingGroupViewModel> in
            return Driver.just(EdittingGroupViewModel(database: database, user: user))
        }
        
        return Output(presentEdittingGroup: presentEdittingGroup)
    }
}
