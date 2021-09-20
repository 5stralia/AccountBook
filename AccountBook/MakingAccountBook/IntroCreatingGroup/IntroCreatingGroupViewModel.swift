//
//  IntroCreatingGroupViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/05.
//

import Foundation

import Firebase
import RxSwift
import RxCocoa

class IntroCreatingGroupViewModel: ViewModel, ViewModelType {
    struct Input {
        let tappedStartButton: Driver<Void>
    }
    struct Output {
        let presentEdittingGroup: Driver<EdittingGroupViewModel>
    }
    
    let provider: ABProvider
    
    init(provider: ABProvider) {
        self.provider = provider
        
        super.init()
    }
    
    func transform(input: Input) -> Output {
        let presentEdittingGroup = input.tappedStartButton.flatMap { [weak self] _ -> Driver<EdittingGroupViewModel> in
            guard let self = self else { return Driver.never() }
            return Driver.just(EdittingGroupViewModel(provider: self.provider))
        }
        
        return Output(presentEdittingGroup: presentEdittingGroup)
    }
}
