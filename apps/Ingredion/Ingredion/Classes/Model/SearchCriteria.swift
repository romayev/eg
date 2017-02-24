//
//  SearchCriteria.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/22/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

struct SearchCriteria {
    static let ALL = { return NSLocalizedString("all", comment: "") }
    
    let attributes: [String] // region, valueProposition, application, etc
    private var criteria: [String: [String]] // region: [APAC, MEX, SA, US & Canada]

    init() {
        self.attributes = []
        criteria = Dictionary()
    }

    init(attributes: [String]) {
        self.attributes = attributes
        criteria = Dictionary()
    }

    private func copyWithCriteria(_ criteria: [String], forAttribute attribute: String) -> SearchCriteria {
        var copy = SearchCriteria(attributes: attributes)
        copy.criteria[attribute] = criteria
        return copy
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
        if value == SearchCriteria.ALL() {
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

    mutating func resetValuesAfter(attributeIndex: Int) {
        for (index, attribute) in attributes.enumerated() where index > attributeIndex {
            criteria[attribute] = nil
        }
    }
}
