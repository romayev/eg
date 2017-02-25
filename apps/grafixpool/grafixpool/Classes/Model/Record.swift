//
//  Record.swift
//  grafixpool
//
//  Created by Alex Romayev on 2/25/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

extension Record {
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        created = NSDate()
        guid = UUID().uuidString
    }
}
