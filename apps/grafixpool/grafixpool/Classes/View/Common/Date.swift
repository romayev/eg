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
        let timeZone = TimeZone(abbreviation: "CET")
        df.timeZone = timeZone
        return "\(df.string(from: self.date)) (CET)"
    }
}
