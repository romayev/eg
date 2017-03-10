//
//  BookingTableCellType.swift
//  grafixpool
//
//  Created by Alex Romayev on 2/27/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

enum BookingTableCellType: Int {
    case slides, project, inDate, notification, outDate, confidentiality, jobType, notes

    var name: String {
        switch self {
        case .slides: return "slides"
        case .project: return "project"
        case .inDate: return "in"
        case .outDate: return "out"
        case .notification: return "notification"
        case .confidentiality: return "confidentiality"
        case .jobType: return "job-type"
        case .notes: return "notes"
        }
    }

    var localizedName: String {
        return NSLocalizedString("booking.edit." + name, comment: "")
    }

    static let count: Int = {
        var max: Int = 0
        while let _ = BookingTableCellType(rawValue: max) { max += 1 }
        return max
    }()

    static let values: [BookingTableCellType] = {
        var values = [BookingTableCellType]()
        var max: Int = 0
        while let type = BookingTableCellType(rawValue: max) {
            max += 1
            values.append(type)
        }
        return values
    }()

    static let localizedValues: [String] = {
        var values = [String]()
        var max: Int = 0
        while let type = BookingTableCellType(rawValue: max) {
            max += 1
            values.append(type.localizedName)
        }
        return values
    }()
}
