//
//  EdittingGroupViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/03.
//

import Foundation

import Firebase
import RxSwift
import RxCocoa

final class EdittingGroupViewModel: ViewModel, ViewModelType {
    struct Input {
        let image: Driver<Data>
        let name: Driver<String?>
        let fee: Driver<Int?>
        let message: Driver<String?>
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
        let alert: PublishRelay<String>
    }
    
    let database: Database
    let user: Observable<User?>
    let group: BehaviorSubject<Group?>
    
    var disposeBag = DisposeBag()
    
    init(database: Database, user: Observable<User?>, group: BehaviorSubject<Group?>) {
        self.database = database
        self.user = user
        self.group = group
        
        super.init()
    }
    
    func transform(input: Input) -> Output {
        let newGroup = BehaviorRelay<Group>(value: Group())
        
        Observable.combineLatest(
            input.name.asObservable(),
            input.fee.asObservable(),
            input.feeTypeSelection.asObservable(),
            input.feeDaySelection.asObservable(),
            input.message.asObservable(),
            input.calculateDaySelection.asObservable()) { name, fee, feeType, feeDay, message, calculateDay -> Group in
            return Group(name: name ?? "",
                         message: message ?? "",
                         fee: fee ?? 0,
                         fee_type: feeType,
                         fee_day: feeDay,
                         calculate_day: calculateDay)
        }
        .bind(to: newGroup)
        .disposed(by: self.disposeBag)
        
        let shouldSubmit = Observable.combineLatest(
            input.name.asObservable(),
            input.fee.asObservable()) { name, fee -> Bool in
            if let name = name, !name.isEmpty,
               let _ = fee {
                return true
            } else {
                return false
            }
        }
        
        let alert = PublishRelay<String>()
        
        input.createGroup.asObservable()
            .flatMap {
                return Observable.zip(newGroup.asObservable(), self.user).take(1)
            }
            .subscribe { event in
                switch event {
                case .next((let newGroup, let user)):
                if let uid = user?.uid {
                    self.database.createGroup(newGroup, uid: uid)
                        .subscribe {
                            self.group.onNext(newGroup)
                        } onError: { _ in
                            alert.accept("그룹 생성에 실패했습니다. 잠시후 다시 시도해주세요.")
                        }
                        .disposed(by: self.disposeBag)

                }
                case .error:
                    alert.accept("그룹 생성에 실패했습니다. 잠시후 다시 시도해주세요.")
                default:
                    break
                }
            }
            .disposed(by: self.disposeBag)
        
        
        return Output(feeType: input.feeTypeSelection.map { $0.rawValue },
                      feeDay: input.feeDaySelection,
                      calculateDay: input.calculateDaySelection,
                      shouldSubmit: shouldSubmit,
                      alert: alert)
    }
    

}
