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

    var name: String = "ERROR"
    let detail: String?
    let notes: String?
    let region: String?
    let valueProposition: String?
    let priority: Int?
    let labelDeclaration: String?

    var displayAttributes: [String] { return Array() }

    override var description: String {
        return name
    }

    func products() -> [Product] {
        return []
    }

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

    func regions() -> String {
        let filtered = products().filter { $0.name == self.name }
        let values: [String] = filtered.map { $0.region! }
        return Array(Set(values)).sorted().joined(separator: ", ")
    }

    func valuePropositions() -> String {
        let filtered = products().filter { $0.name == self.name }
        let values: [String] = filtered.map { $0.region! }
        return Array(Set(values)).sorted().joined(separator: ", ")
    }

    func valuesForProperty(property: String) -> String {
        let filtered = products().filter { $0.name == self.name }
        let values: [String] = filtered.map { $0.region! }
        return Array(Set(values)).sorted().joined(separator: ", ")
    }

//    func valuesForProperty(property: String, products: Array<Product>) -> String {
//        // Find products matching the name property
//        let filtered = products.filter { $0.name == self.name }
//        // Extract an array that contains the passed in property
//        let values: Array<String> = Array() // In Objective-C this would be filtered.valueForKey(property)
//        // Get unique values, sort return String (I suppose I could use reduce() instead of joined()
//        return Array(Set(values)).sorted().joined(separator: ", ")
//    }

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
