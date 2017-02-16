//
//  Product.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/12/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

extension Array where Element : Product {
    var uniqueSorted: [Element] {
        return Array(Set(self)).sorted()
    }
}

class Product : NSObject, Comparable {
    enum ProductType: Int {
        case battersAndBreadings
        case beverages
        case carrageenan
        case confectionery
        case creamySalad
        case hydrocolloids
        case meat
        case processedCheese
        case yogurt
        case tomatoBasedSauses
        case productTypeCount

        func isImplemented() -> Bool {
            return self == .confectionery || self == .beverages
        }

        static let count: Int = {
            var max: Int = 0
            while let _ = ProductType(rawValue: max) { max += 1 }
            return max
        }()
    }

    // MARK: Attributes
    var name: String = "ERROR"
    let detail: String?
    let notes: String?
    let region: String?
    let valueProposition: String?
    let priority: Int?
    let labelDeclaration: String?

    init(_ dictionary: Dictionary<String, Any>) {
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

    var products: [Product] {
        return []
    }

    var displayAttributes: [String] { return Array() }

    func regions() -> String { return uniquePropertyValues("region") }
    func valuePropositions() -> String { return uniquePropertyValues("valueProposition") }

    func uniquePropertyValues(_ property: String) -> String {
        let filtered = products.filter { $0.name == self.name }
        let values: [String] = filtered.flatMap { $0.value(forKey: property) as? String }
        return Array(Set(values)).sorted().joined(separator: ", ")
    }

    func usersPriority() -> Bool {
        return products.filter({ $0.priority != nil }).count > 0
    }

    func uniqueValuesWithProperty(property: String, products: Array<Product>.Element) -> Array<String> {
        let array: Array<String> = Array<String>()
        return array 
    }

    // MARK: Comparable
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
