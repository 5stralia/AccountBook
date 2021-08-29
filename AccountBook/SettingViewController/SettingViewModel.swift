//
//  SettingViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import Foundation

import Firebase
import RxSwift
import RxCocoa
import RxDataSources

class SettingViewModel: ViewModel {
    struct Input {
        let refresh: Observable<Void>
        let didSelect: Driver<SettingSectionItem>
    }
    
    struct Output {
        let items: BehaviorRelay<[SettingSection]>
        let showAlert: PublishRelay<String>
    }
    
    let isSignIn: BehaviorRelay<Bool>
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    let disposeBag = DisposeBag()
    
    init() {
        self.isSignIn = BehaviorRelay<Bool>(value: Auth.auth().currentUser != nil)
        
        self.authHandle = Auth.auth().addStateDidChangeListener { auth, user in
            // 로그인 상태 변경 리스너
            self.isSignIn.accept(user != nil)
        }
    }
    
    deinit {
        if let handle = self.authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[SettingSection]>(value: [])
        
        let showAlert = PublishRelay<String>()
        
        Observable.combineLatest(input.refresh, self.isSignIn.asObservable().map { _ in }).map { [weak self] (_) -> [SettingSection] in
            guard let self = self else { return [] }
            
            var items = [SettingSection]()
            
            if self.isSignIn.value {
                items.append(.profile(title: "Profile", items: [
                    .logOutItem(viewModel: TableViewCellViewModel(title: "로그아웃", detail: nil, isHiddenAccesoryImageView: true))
                ]))
            }
            
            return items
        }
        .bind(to: elements)
        .disposed(by: self.disposeBag)
        
        input.didSelect.asObservable().subscribe(onNext: { item in
            switch item {
            case .logOutItem:
                let firebaseAuth = Auth.auth()
                do {
                    try firebaseAuth.signOut()
                    
                    showAlert.accept("로그아웃 완료")
                    self.isSignIn.accept(false)
                } catch let signOutError as NSError {
                    print("Error signing out: %@", signOutError)
                }
            }
        })
        .disposed(by: self.disposeBag)
        
        return Output(items: elements, showAlert: showAlert)
    }
}
