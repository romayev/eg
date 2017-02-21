//
//  Product.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/12/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

class Product : NSObject {
    // MARK: Attributes
    var productType: ProductType
    var name: String = "ERROR"
    let detail: String?
    let notes: String?
    let region: String?
    let valueProposition: String?
    let priority: Int?
    let labelDeclaration: String?

    subscript(key: String) -> String? {
        return value(forKey: key) as? String
    }

    init(_ dictionary: Dictionary<String, Any>) {
        productType = .beverages
        if let name: String = dictionary["productName"] as? String {
            self.name = name
        }
        detail = dictionary["productDescription"] as? String
        notes = dictionary["productNotes"] as? String
        region = dictionary["region"] as? String
        valueProposition = dictionary["valueProposition"] as? String
        priority = dictionary["priority"] as? Int
        labelDeclaration = dictionary["labelDeclaration"] as? String
    }

    override var description: String {
        return name
    }

    // MARK: Queries
    func regions() -> String { return productType.propertyValues("region", in: self) }
    func valuePropositions() -> String { return productType.propertyValues("valueProposition", in: self) }

    func usersPriority() -> Bool {
        return productType.products.filter({ $0.priority != nil }).count > 0
    }
}

extension Product: Comparable {
    static func <(lhs: Product, rhs: Product) -> Bool {
        return lhs.name < rhs.name
    }

    static func <=(lhs: Product, rhs: Product) -> Bool {
        return lhs.name <= rhs.name
    }

    static func >(lhs: Product, rhs: Product) -> Bool {
        return lhs.name > rhs.name
    }

    static func >=(lhs: Product, rhs: Product) -> Bool {
        return lhs.name >= rhs.name
    }
}
