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
    
    let provider: ABProvider
    
    var disposeBag = DisposeBag()
    
    init(provider: ABProvider) {
        self.provider = provider
        
        super.init()
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[ViewModel]>(value: [])
        
        Observable.combineLatest(self.provider.user.asObservable(),
                                 self.provider.group.groupDocumentModel.asObservable()) { [weak self] (user, group) -> [ViewModel] in
            guard let self = self else { return [] }
            
            if let _ = user {
                if let _ = group {
                    let profileViewModel = ProfileViewModel(provider: self.provider)
                    let chartViewModel = ChartViewModel()
                    let listViewModel = ListViewModel(provider: self.provider)
                    let settingViewModel = SettingViewModel()
                    
                    return [
                        profileViewModel,
                        chartViewModel,
                        listViewModel,
                        settingViewModel
                    ]
                } else {
                    return [IntroCreatingGroupViewModel(provider: self.provider)]
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
