//
//  ProfileMembersCellViewModel.swift
//  AccountBook
//
//  Created by Hoju Choi on 2022/05/16.
//

import RxRelay
import RxSwift

final class ProfileMembersCellViewModel {
    let name: BehaviorRelay<String>
    
    let role: [GroupRole]
    
    init(name: String, role: [GroupRole]) {
        self.name = BehaviorRelay<String>(value: name)
        self.role = role
    }
}
