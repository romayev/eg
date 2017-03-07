//
//  Date.swift
//  grafixpool
//
//  Created by Alex Romayev on 3/6/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

extension NSDate {
    var date: Date {
        return Date(timeIntervalSinceReferenceDate: self.timeIntervalSinceReferenceDate)
    }
    var format: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        df.doesRelativeDateFormatting = true
        return df.string(from: self.date)
    }
    var formatCET: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        df.doesRelativeDateFormatting = true
        return "\(df.string(from: self.date)) (CET)"
    }
    var inCETTimeZone: NSDate {
        let current = TimeZone.current
        guard let cet = TimeZone(abbreviation: "CET") else {
            fatalError()
        }
        let currentOffset = current.secondsFromGMT()
        let cetOffet = cet.secondsFromGMT()
        let diff: TimeInterval = TimeInterval(currentOffset - cetOffet)
        return NSDate(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate - diff)
    }
}
