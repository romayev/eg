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
        return NSLocalizedString(self, comment: "")
    }
}
