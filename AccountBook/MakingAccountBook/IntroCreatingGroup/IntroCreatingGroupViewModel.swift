//
//  IntroCreatingGroupViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/05.
//

import Foundation

import Firebase
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
    let user: Observable<User?>
    let group: BehaviorSubject<Group?>
    
    init(database: Database, user: Observable<User?>, group: BehaviorSubject<Group?>) {
        self.database = database
        self.user = user
        self.group = group
        
        super.init()
    }
    
    func transform(input: Input) -> Output {
        let database = self.database
        
        let presentEdittingGroup = input.tappedStartButton.flatMap { [weak self] _ -> Driver<EdittingGroupViewModel> in
            guard let self = self else { return Driver.never() }
            return Driver.just(EdittingGroupViewModel(database: database, user: self.user, group: self.group))
        }
        
        return Output(presentEdittingGroup: presentEdittingGroup)
    }
}
