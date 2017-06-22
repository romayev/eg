//
//  String.swift
//  EGKit
//
//  Created by Alex Romayev on 3/27/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

extension String {
    public var localized: String {
        let common = Bundle.main.localizedString(forKey: self, value: "", table: "Common")
        return common == self ? NSLocalizedString(self, comment: "") : common
    }
}
