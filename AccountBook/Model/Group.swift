//
//  Group.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/03.
//

import Foundation

import Firebase

// MARK: - Group
struct Group: Codable {
    var name: String = ""
    var message: String = ""
    var fee: Int = 0
    var fee_type: FeeType = .monthly
    var fee_day: Int = 1
    var calculate_day: Int = 1
    var users: [GroupUser] = []
    var accounts: [GroupAccount] = []
}

// MARK: - GroupAccount
struct GroupAccount: Codable {
    var date: Date
    var name: String
    var amount: Int
    var category: String
    var payer: String
    var participants: [String]
}

// MARK: - GroupUser
struct GroupUser: Codable {
    var uid: String
    var name: String
    var unpaid_amount: Int
    var role: GroupRole
}

enum FeeType: String, Codable {
    case daily
    case weekly
    case biweekly
    case monthly
    case bimonthly
    case yealy
    case quarterly
}

enum GroupRole: String, Codable {
    case all
    case reader
    case writer
}
