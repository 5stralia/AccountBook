//
//  EdittingNameViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/06.
//

import Foundation

import RxSwift

final class EdittingNameViewModel: ViewModel, ViewModelType {
    struct Input {
        let editName: Observable<Void>
        let nameText: Observable<String>
    }
    struct Output {
        let groupNameText: BehaviorSubject<String>
        let peopleCountText: BehaviorSubject<String>
        let feeText: BehaviorSubject<String>
        let userNameText: BehaviorSubject<String?>
    }
    
    let database: Database
    let user: ABUser
    let createdGroup: Group
    
    init(database: Database, user: ABUser, createdGroup: Group) {
        self.database = database
        self.user = user
        self.createdGroup = createdGroup
        
        super.init()
    }
    
    func transform(input: Input) -> Output {
        let groupNameText = BehaviorSubject<String>(value: self.createdGroup.name)
        let peopleCountText = BehaviorSubject<String>(value: "인원 : 1명")
        let feeText = BehaviorSubject<String>(value: self.feeText(feeType: self.createdGroup.fee_type,
                                                                  fee: self.createdGroup.fee))
        let userNameText = self.user.name
        
        return Output(groupNameText: groupNameText,
                      peopleCountText: peopleCountText,
                      feeText: feeText,
                      userNameText: userNameText)
    }
    
    private func feeText(feeType: FeeType, fee: Int) -> String {
        return "회비 : \(feeType.korean) \(fee.priceString() ?? "0")원"
    }
}
