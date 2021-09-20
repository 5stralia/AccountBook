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
    
    let provider: ABProvider
    
    var disposeBag = DisposeBag()
    
    init(provider: ABProvider) {
        self.provider = provider
        
        super.init()
    }
    
    func transform(input: Input) -> Output {
        let newGroup = BehaviorRelay<GroupDocumentModel>(value: GroupDocumentModel())
        
        Observable.combineLatest(
            input.name.asObservable(),
            input.fee.asObservable(),
            input.feeTypeSelection.asObservable(),
            input.feeDaySelection.asObservable(),
            input.message.asObservable(),
            input.calculateDaySelection.asObservable()) { name, fee, feeType, feeDay, message, calculateDay -> GroupDocumentModel in
            return GroupDocumentModel(name: name ?? "",
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
                return Observable.zip(newGroup.asObservable(), self.provider.user).take(1)
            }
            .subscribe { event in
                switch event {
                case .next((let newGroup, let user)):
                if let uid = user?.uid {
                    self.provider.api.createGroup(newGroup, uid: uid)
                        .subscribe {
                            self.provider.group.groupDocumentModel.onNext(newGroup)
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
