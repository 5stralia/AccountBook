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
        let group: Observable<GroupDocumentModel?>
    }
    
    let provider: ABProvider
    
    init(provider: ABProvider) {
        self.provider = provider
        
        super.init()
    }
    
    func transform(input: Input) -> Output {
        return Output(group: self.provider.group.groupDocumentModel)
    }
}
