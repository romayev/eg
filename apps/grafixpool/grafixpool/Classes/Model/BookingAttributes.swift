//
//  BookingAttributes.swift
//  grafixpool
//
//  Created by Alex Romayev on 2/27/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

enum Confidentiality: Int {
    case level1 = 1, level2, level3
    var localizedName: String {
        switch self {
        case .level1:
            return NSLocalizedString("confidentiality.level1", comment: "")
        case .level2:
            return NSLocalizedString("confidentiality.level2", comment: "")
        case .level3:
            return NSLocalizedString("confidentiality.level3", comment: "")
        }
    }
    var coreDataValue: Int16 {
        return Int16(rawValue)
    }

    static let defaultValue = Confidentiality.level2
    static let all = [Confidentiality.level1, Confidentiality.level2, Confidentiality.level3]
    static let localizedValues: [String] = {
        var values = [String]()
        for type in Confidentiality.all {
            values.append(type.localizedName)
        }
        return values
    }()

    init?(coreDataValue: Int16) {
        self.init(rawValue: Int(coreDataValue))
    }
}
