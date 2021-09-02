//
//  SettingViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import Foundation

import FBSDKLoginKit
import Firebase
import RxSwift
import RxCocoa
import RxDataSources

class SettingViewModel: ViewModel, ViewModelType {
    struct Input {
        let refresh: Observable<Void>
        let didSelect: Driver<SettingSectionItem>
    }
    
    struct Output {
        let items: BehaviorRelay<[SettingSection]>
        let didSignOut: PublishRelay<Void>
    }
    
    let isSignIn: BehaviorRelay<Bool>
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    let disposeBag = DisposeBag()
    
    override init() {
        self.isSignIn = BehaviorRelay<Bool>(value: Auth.auth().currentUser != nil)
        
        super.init()
        
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
        
        let didSignOut = PublishRelay<Void>()
        
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
                    LoginManager().logOut()
                    
                    self.isSignIn.accept(false)
                    didSignOut.accept(())
                } catch let signOutError as NSError {
                    print("Error signing out: %@", signOutError)
                }
            }
        })
        .disposed(by: self.disposeBag)
        
        return Output(items: elements, didSignOut: didSignOut)
    }
}
