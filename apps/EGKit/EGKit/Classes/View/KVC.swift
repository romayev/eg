//
//  KVC.swift
//  EGKit
//
//  Created by Alex Romayev on 2/27/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

public protocol KVC {
    func valueForKey(key : String) -> Any?
}

public extension KVC {
    func valueForKey(key : String) -> Any? {
        let mirror = Mirror(reflecting: self)
        for (_, attr) in mirror.children.enumerated() {
            if attr.label == key {
                return attr.value
            }
        }
        return nil
    }
}
