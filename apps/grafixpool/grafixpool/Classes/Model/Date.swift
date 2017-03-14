//
//  Date.swift
//  grafixpool
//
//  Created by Alex Romayev on 3/6/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

extension NSDate {
    var format: String {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        df.doesRelativeDateFormatting = true
        return df.string(from: self as Date)
    }
    var removingTime: NSDate {
        let calendar = NSCalendar.current
        let comps = calendar.dateComponents([.year, .month, .day], from: (self as Date))
        let date = calendar.date(from: comps)
        return date! as NSDate;
    }
    var formatCET: String {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        df.doesRelativeDateFormatting = true
        return "\(df.string(from: self as Date)) (CET)"
    }
    var formatCETEmail: String {
        guard let cet = TimeZone(abbreviation: "CET") else {
            fatalError()
        }
        let df = DateFormatter()
        df.locale = Locale(identifier: "de_DE")
        df.timeZone = cet
        df.dateStyle = .short
        df.timeStyle = .short
        return "\(df.string(from: self as Date)) CET"
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

func isCurrentTimeZoneCET() -> Bool {
    let current = TimeZone.current
    guard let cet = TimeZone(abbreviation: "CET") else {
        fatalError()
    }
    return current == cet
}
