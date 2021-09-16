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
        let items: BehaviorRelay<[ViewModel]>
    }
    
    let database: Database
    let user = BehaviorSubject<User?>(value: Auth.auth().currentUser)
    let group = BehaviorSubject<Group?>(value: nil)
    
    var disposeBag = DisposeBag()
    
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    init(database: Database) {
        self.database = database
        
        super.init()
        
        self.authHandle = Auth.auth().addStateDidChangeListener { auth, user in
            self.user.onNext(user)
        }
    }
    
    deinit {
        if let handle = self.authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func addStateDidChangeListener() {
        self.authHandle = Auth.auth().addStateDidChangeListener { auth, user in
            self.user.onNext(user)
        }
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[ViewModel]>(value: [])
        
        // FIXME: 그룹 생성 후에 새로고침
        self.user.asObservable()
            .flatMap { [weak self] user -> Single<Group?> in
                guard let self = self, let uid = user?.uid else { return Single.just(nil) }
                return self.database.currentGroup(uid: uid)
            }
            .bind(to: self.group)
            .disposed(by: self.disposeBag)
        
        Observable.combineLatest(self.user.asObservable(),
                                 self.group.asObservable()) { [weak self] (user, group) -> [ViewModel] in
            guard let self = self else { return [] }
            
            if let _ = user {
                if let _ = group {
                    let profileViewModel = ProfileViewModel(database: self.database,
                                                            user: self.user.asObservable(),
                                                            group: self.group.asObservable())
                    let chartViewModel = ChartViewModel()
                    let listViewModel = ListViewModel()
                    let settingViewModel = SettingViewModel()
                    
                    return [
                        profileViewModel,
                        chartViewModel,
                        listViewModel,
                        settingViewModel
                    ]
                } else {
                    return [IntroCreatingGroupViewModel(database: self.database,
                                                        user: self.user.asObservable(),
                                                        group: self.group)]
                }
                
            } else {
                return [SignInViewModel()]
            }
        }
        .bind(to: elements)
        .disposed(by: self.disposeBag) 
        
        return Output(items: elements)
    }
}
