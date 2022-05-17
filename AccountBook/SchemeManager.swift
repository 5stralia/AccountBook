//
//  SchemeManager.swift
//  AccountBook
//
//  Created by Hoju Choi on 2022/05/17.
//

import Foundation

import RxSwift

final class SchemeManager {
    let provider: ABProvider
    let url: URL
    
    private var disposeBag = DisposeBag()
    
    init(provider: ABProvider, url: URL) {
        self.provider = provider
        self.url = url
    }
    
    func run() {
        let components = URLComponents(string: url.absoluteString)
        let querys = querys(components?.queryItems ?? [])
        
        guard let host = url.host,
              let action = SchemeManager.Action(rawValue: host)
        else { return }
        
        switch action {
        case .invite:
            if let id = querys["id"] {
                provider.requestJoin(id: id)
                    .subscribe { event in
                        switch event {
                        case .completed:
                            print("성공이염")
                        case .error(let error):
                            print("에러염", error)
                        }
                    }
                    .disposed(by: disposeBag)
            }
        }
    }
    
    private func querys(_ queryItems: [URLQueryItem]) -> [String: String] {
        var dict = [String: String]()
        for item in queryItems {
            dict[item.name] = item.value
        }
        
        return dict
    }
}

extension SchemeManager {
    enum Action: String {
        case invite = "invite"
    }
}
