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
        let inviteMembers: Observable<Void>
    }
    struct Output {
        let isManager: Observable<Bool>
        let items: BehaviorRelay<[ProfileMembersCellViewModel]>
        let invite: Observable<String>
        let failureInvitation: Observable<Void>
    }

    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[ProfileMembersCellViewModel]>(value: [])
        
        let isManager = Observable.zip(
            provier.user,
            provier.group.members
        ) { user, members -> Bool in
            guard let user = user,
                  let userIndex = members.firstIndex(where: { $0.uid == user.uid })
            else { return false }
            
            return members[userIndex].role.contains(.manager)
        }
        
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
        
        let failureInvitation = PublishRelay<Void>()
        let invite = input.inviteMembers
            .withUnretained(self)
            .flatMap { own, _ in own.provier.createInvitation() }
            .catch({ _ -> Observable<String> in
                failureInvitation.accept(())
                
                return .never()
            })
            .withLatestFrom(provier.user) { ($0, $1) }
            .compactMap { id, user -> String? in
                guard let name = user?.displayName else { return nil }
                
                return  """
                        \(name)님이 같이가계부로 초대합니다!
                        gati://invite?id=\(id)
                        """
            }
        
        return Output(
            isManager: isManager,
            items: elements,
            invite: invite,
            failureInvitation: failureInvitation.asObservable()
        )
    }
}
