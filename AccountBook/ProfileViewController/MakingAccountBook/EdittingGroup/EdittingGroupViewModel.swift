//
//  EdittingGroupViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/03.
//

import Foundation

import RxSwift
import RxCocoa

final class EdittingGroupViewModel: ViewModel, ViewModelType {
    struct Input {
        let image: Driver<Data>
        let name: Driver<String>
        let fee: Driver<Int>
        let message: Driver<String>
        let feeTypeSelection: Driver<FeeType>
        let feeDaySelection: Driver<Int>
        let calculateDaySelection: Driver<Int>
        let createGroup: Driver<Void>
    }
    struct Output {
        let feeType: Driver<String>
        let feeDay: Driver<Int>
        let calculateDay: Driver<Int>
        let shouldSubmit: Observable<Bool>
        let close: PublishRelay<Void>
        let alert: PublishRelay<String>
    }
    
    let database: Database
    let user: ABUser
    var disposeBag = DisposeBag()
    
    init(database: Database, user: ABUser) {
        self.database = database
        self.user = user
        
        super.init()
    }
    
    func transform(input: Input) -> Output {
        let newGroup = BehaviorRelay<Group>(value: Group())
        
        Observable.combineLatest(
            self.user.uid.compactMap { $0 }.asObservable(),
            input.name.asObservable(),
            input.fee.asObservable(),
            input.feeTypeSelection.asObservable(),
            input.feeDaySelection.asObservable(),
            input.message.asObservable(),
            input.calculateDaySelection.asObservable()) { uid, name, fee, feeType, feeDay, message, calculateDay -> Group in
            let user = GroupUser(uid: uid,
                                 name: "그룹장",
                                 unpaid_amount: 0,
                                 role: .all)
            
            return Group(name: name,
                         message: message,
                         fee: fee,
                         fee_type: feeType,
                         fee_day: feeDay,
                         calculate_day: calculateDay,
                         users: [user],
                         accounts: [])
        }
        .bind(to: newGroup)
        .disposed(by: self.disposeBag)
        
        let shouldSubmit = Observable.combineLatest(
            input.name.asObservable(),
            input.fee.asObservable()) { name, fee in
            return !name.isEmpty
        }
        
        let close = PublishRelay<Void>()
        let alert = PublishRelay<String>()
        
        input.createGroup.asObservable().flatMap { [weak self] _ -> Single<Void> in
            guard let self = self,
                  let uid = try? self.user.uid.value() else { return Single.never() }
            return self.database.createGroup(newGroup.value, uid: uid)
        }
        .subscribe { event in
            switch event {
            case .next:
                close.accept(())
            case .error:
                alert.accept("에러가 발생했습니다. 잠시후 다시 시도해주세요.")
            case .completed:
                break
            }
        }
        .disposed(by: self.disposeBag)
        
        return Output(feeType: input.feeTypeSelection.map { $0.rawValue },
                      feeDay: input.feeDaySelection,
                      calculateDay: input.calculateDaySelection,
                      shouldSubmit: shouldSubmit,
                      close: close,
                      alert: alert)
    }
    

}
