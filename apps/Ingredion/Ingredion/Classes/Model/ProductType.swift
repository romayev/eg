//
//  ProductType.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/20/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

enum ProductType: Int {
    case battersAndBreadings, beverages, carrageenan, confectionery, creamySalad, hydrocolloids, meat, processedCheese, tomatoBasedSauses, yogurt

    var localizedName: String {
        let key = "index.title \(self.rawValue)"
        return NSLocalizedString(key, comment: key)
    }
    var implemented: Bool { return self == .confectionery || self == .beverages }

    var products: [Product] {
        switch self {
        case .beverages:
            return DataManager.manager.beverages
        case .confectionery:
            return DataManager.manager.confectionery
        default:
            return DataManager.manager.confectionery
        }
    }

    var searchCriteria: [String] {
        switch self {
        case .beverages:
            return ["region", "segment", "valueProposition", "labelDeclaration", "base"]
        case .confectionery:
            return ["region", "valueProposition", "application"]
        default:
            return []
        }
    }

    var displayAttributes: [String] {
        switch self {
        case .beverages:
            return ["base", "labelDeclaration", "regions", "starchUseLabel", "valuePropositions", "fatContent", "proteinContent", "features"]
        case .confectionery:
            return ["regions", "valuePropositions", "applications", "notes", "labelDeclaration", "selectionCriteria", "recommendedMaxUsage"]
        default:
            return []
        }
    }

    static let count: Int = {
        var max: Int = 0
        while let _ = ProductType(rawValue: max) { max += 1 }
        return max
    }()

    // MARK: Search
    func dropDownValues(property: String, in products: [Product]) -> [String] {
        var values = propertyValues(property, in: products)
        values.insert(NSLocalizedString("all", comment: "all"), at: 0)
        return values
    }

    func productsWithSearchCriteria(_ searchCriteria: [String: [String]]) -> [Product] {
        let filtered = products.filter {
            var match = true
            for (property, criteria) in searchCriteria {
                if !isAll(criteria) {
                    if let value: String = $0[property] {
                        match = match && criteria.contains(value)
                        if !match {
                            return false
                        }
                    } else {
                        return false
                    }
                }
            }
            return match
        }
        let unique = Array(Set(filtered))
        // FIXME: Sort
        return unique
    }

    func propertyValues(_ property: String, in product: Product) -> String {
        let filtered = products.filter { $0.name == product.name }
        return propertyValues(property, in: filtered).joined(separator: ", ")
    }

    func propertyValues(_ property: String, in products: [Product]) -> [String] {
        let propertyValues: [String] = products.flatMap { $0[property] }
        return Array(Set(propertyValues)).sorted()
    }

    private func isAll (_ criteria: [String]) -> Bool {
        return criteria.count == 1 && criteria.first == "All"
    }
}

