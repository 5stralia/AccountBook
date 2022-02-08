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
        
        let title: Observable<String>
        let groupImageURLString: Observable<String>
        let message: Observable<String>
        let members: Observable<[ProfileMemberCellViewModel]>
        let fee: Observable<String>
    }
    
    let provider: ABProvider
    
    init(provider: ABProvider) {
        self.provider = provider
        
        super.init()
    }
    
    func transform(input: Input) -> Output {
        let title = BehaviorRelay<String>(value: "?")
        let groupImageURLString = BehaviorRelay<String>(value: "")
        let message = BehaviorRelay<String>(value: "?")
        let members = BehaviorRelay<[ProfileMemberCellViewModel]>(value: [
            ProfileMemberCellViewModel(),
            ProfileMemberCellViewModel(),
            ProfileMemberCellViewModel()
        ])
        let fee = BehaviorRelay<String>(value: "매달 ?원")
        
        provider.group.groupDocumentModel
            .compactMap { $0?.name }
            .map { "\($0) " }
            .bind(to: title)
            .disposed(by: disposeBag)
        
        provider.group.groupDocumentModel
            .compactMap { $0?.message }
            .map { "\"\($0)\"" }
            .bind(to: message)
            .disposed(by: disposeBag)
        
        provider.group.members
            .map { $0.map ({ _ in ProfileMemberCellViewModel() }) }
            .bind(to: members)
            .disposed(by: disposeBag)
        
        provider.group.groupDocumentModel
            .compactMap { $0?.fee }
            .map { "매달 \($0.priceString() ?? "0")원" }
            .bind(to: fee)
            .disposed(by: disposeBag)
        
        return Output(
            group: self.provider.group.groupDocumentModel,
            title: title.asObservable(),
            groupImageURLString: groupImageURLString.asObservable(),
            message: message.asObservable(),
            members: members.asObservable(),
            fee: fee.asObservable()
        )
    }
}
