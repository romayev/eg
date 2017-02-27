//
//  Image.swift
//  grafixpool
//
//  Created by Alex Romayev on 2/27/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    enum AssetIdentifier: String {
        case logo = "Logo"
    }
    convenience init(assetItentifier: AssetIdentifier) {
        self.init(named: assetItentifier.rawValue)!
    }
}
