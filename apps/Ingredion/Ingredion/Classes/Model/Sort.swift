//
//  Sort.swift
//  Ingredion
//
//  Created by Alex Romayev on 3/18/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

typealias SortDescriptor<Value> = (Value, Value) -> Bool

func combine<Value>(sortDescriptors: [SortDescriptor<Value>]) -> SortDescriptor<Value> {
    return { lhs, rhs in
        for isOrderedBefore in sortDescriptors {
            if isOrderedBefore(lhs,rhs) { return true }
            if isOrderedBefore(rhs,lhs) { return false }
        }
        return false
    }
}
