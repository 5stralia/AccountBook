//
//  ViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import Foundation

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
