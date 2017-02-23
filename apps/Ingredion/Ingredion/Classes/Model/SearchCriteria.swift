//
//  SearchCriteria.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/22/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

struct SearchCriteria {
    let attributes: [String]
    private var criteria: [String: [String]]

    init() {
        self.attributes = []
        criteria = Dictionary()
    }

    init(attributes: [String]) {
        self.attributes = attributes
        criteria = Dictionary()
    }

    func matches(_ item: Product) -> Bool {
        var match = true
        for (property, criteria) in criteria {
            if let value: String = item[property] {
                match = match && criteria.contains(value)
                if !match {
                    return false
                }
            } else {
                return false
            }
        }
        return match
    }

    func valuesForAttributeAtIndex(_ index: Int) -> [String]? {
        guard attributes.count >= index else {
            print("ERROR: Index \(index) is out of bounds \(attributes.count)")
            return nil
        }
        return criteria[attributes[index]]
    }

    mutating func toggleValueForAttribute(_ attribute: String, value: String) {
        guard attributes.contains(attribute) else {
            print("Illegal attribute: " + attribute)
            return
        }
        if value == "All" {
            criteria[attribute] = nil
        } else {
            if var values = criteria[attribute] {
                if values.contains(value) {
                    values.remove(object: value)
                    criteria[attribute] = values
                } else {
                    values.append(value)
                    values.sort()
                    criteria[attribute] = values
                }
            } else {
                criteria[attribute] = [value]
            }
        }
    }
}
