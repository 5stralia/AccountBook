//
//  Int+Format.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/06.
//

import Foundation

extension Int {
    func priceString() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: self as NSNumber)
    }
}
