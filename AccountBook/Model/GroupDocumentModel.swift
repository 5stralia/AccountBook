//
//  Group.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/03.
//

import Foundation

import Firebase

// MARK: - GroupDocumentModel
struct GroupDocumentModel: Codable {
    var name: String = ""
    var message: String = ""
    var fee: Int = 0
    var fee_type: FeeType = .monthly
    var fee_day: Int = 1
    var calculate_day: Int = 1
    var categorys: [String] = []
}

// MARK: - GroupAccount
struct AccountDocumentModel: Codable {
    var date: Date
    var name: String
    var amount: Int
    var category: String
    var payer: String
    var participants: [String]
}

// MARK: - GroupUser
struct MemberDocumentModel: Codable {
    var uid: String
    var name: String
    var role: [GroupRole]
}

enum FeeType: String, Codable {
    case daily
    case weekly
    case biweekly
    case monthly
    case bimonthly
    case yealy
    case quarterly
    
    var korean: String {
        switch self {
        case .daily: return "매일"
        case .weekly: return "매주"
        case .biweekly: return "격주"
        case .monthly: return "매달"
        case .bimonthly: return "격달"
        case .yealy: return "매년"
        case .quarterly: return "분기별"
        }
    }
}

enum GroupRole: String, Codable {
    case admin
    case manager
}
