//
//  ProfileViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import Foundation

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
    let user: ABUser
    
    var disposeBag = DisposeBag()
    
    init(database: Database, user: ABUser) {
        self.database = database
        self.user = user
        
        super.init()
    }
    
    func transform(input: Input) -> Output {
        let group = Observable.combineLatest(input.viewWillAppear,
                                             self.user.uid.asObservable()) { _, uid in
            return uid
        }
        .flatMap { [weak self] uid -> Single<Group?> in
            guard let self = self,
                  let uid = uid
            else { return Single.never() }
            
            return self.database.currentGroup(uid: uid)
        }
        
        return Output(group: group)
    }
}
