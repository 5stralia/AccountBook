//
//  ProfileViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import Foundation

import Firebase
import RxSwift
import RxCocoa

class ProfileViewModel: ViewModel, ViewModelType {
    struct Input {
        let viewWillAppear: Observable<Void>
    }
    struct Output {
        let group: Observable<Group?>
    }
    
    let database: Database
    let user: Observable<User?>
    let group: Observable<Group?>
    
    var disposeBag = DisposeBag()
    
    init(database: Database, user: Observable<User?>, group: Observable<Group?>) {
        self.database = database
        self.user = user
        self.group = group
        
        super.init()
    }
    
    func transform(input: Input) -> Output {
        return Output(group: self.group)
    }
}
