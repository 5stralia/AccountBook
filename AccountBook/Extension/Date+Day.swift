//
//  Date+Day.swift
//  AccountBook
//
//  Created by 최호주 on 2021/10/24.
//

import Foundation

extension Date {
    func firstDay() -> Date {
        return Calendar.current.date(
            from: Calendar.current.dateComponents([.year,.month],
                                                  from: Calendar.current.startOfDay(for: self)))!
    }
    
    func lastDay() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.firstDay())!
    }
    
    func backwardMonth(_ value: Int) -> Date {
       return Calendar.current.date(byAdding: .month, value: -value, to: self.firstDay())!
    }
    
    func forwardMonth(_ value: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: value, to: self.firstDay())!
    }
}
