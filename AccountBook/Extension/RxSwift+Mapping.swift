//
//  RxSwift+Mapping.swift
//  AccountBook
//
//  Created by Hoju Choi on 2022/05/17.
//

import RxSwift

extension ObservableType {
    func mapToVoid() -> Observable<Void> {
        return self.map { _ in }
    }
}
