//
//  DatabaseError.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/06.
//

import Foundation

enum DatabaseError: Error {
    case invalidKey(String)
    case decodingFail
    case emptyGroups
}
