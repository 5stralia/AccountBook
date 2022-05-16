//
//  ProfileMembersViewModel.swift
//  AccountBook
//
//  Created by Hoju Choi on 2022/02/09.
//

import Foundation

import RxRelay
import RxSwift

final class ProfileMembersViewModel: ViewModel {
    let provier: ABProvider
    
    init(provier: ABProvider) {
        self.provier = provier
    }
 
}

extension ProfileMembersViewModel: ViewModelType {
    struct Input {
        let searchMember: Observable<String?>
        let inviteMembers: Observable<Int>
    }
    struct Output {
        let items: BehaviorRelay<[ProfileMembersCellViewModel]>
    }

    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[ProfileMembersCellViewModel]>(value: [])
        
        let members = provier.group.members
            .map { members -> [ProfileMembersCellViewModel] in
                members.map { member -> ProfileMembersCellViewModel in
                    return ProfileMembersCellViewModel(name: member.name, role: member.role)
                }
            }
        
        let searching = Observable.combineLatest(
            input.searchMember,
            members
        ) { searching, members -> [ProfileMembersCellViewModel] in
            guard let searching = searching,
                  !searching.isEmpty
            else {
                return members
            }
            
            return members.filter { $0.name.value.contains(searching) }
        }
        
        Observable.merge(members, searching).bind(to: elements).disposed(by: disposeBag)
        
        return Output(
            items: elements
        )
    }
}
