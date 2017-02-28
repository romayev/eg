//
//  BookingTableCellType.swift
//  grafixpool
//
//  Created by Alex Romayev on 2/27/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

enum BookingTableCellType: Int {
    case taskType, due, preferred, layout, slides, aspectRatio, confidentiality

    var name: String {
        switch self {
        case .taskType: return "type"
        case .due: return "due"
        case .preferred: return "preferred"
        case .layout: return "layout"
        case .slides: return "slides"
        case .aspectRatio: return "aspect-ratio"
        case .confidentiality: return "confidentiality"
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
