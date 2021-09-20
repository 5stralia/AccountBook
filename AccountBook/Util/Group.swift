//
//  GroupManager.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/20.
//

import Foundation

import RxSwift

struct Group {
    let groupDocumentModel = BehaviorSubject<GroupDocumentModel?>(value: nil)
    let accounts = BehaviorSubject<[AccountDocumentModel]>(value: [])
    let members = BehaviorSubject<[MemberDocumentModel]>(value: [])
}
