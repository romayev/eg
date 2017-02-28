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

    var module: String {
        switch self {
        case .beverages:
            return "beverages"
        case .confectionery:
            return "confectionery"
        default:
            return "not implemented"
        }
    }
    var localizedName: String {
        let key = "index.title.\(self.rawValue)"
        return NSLocalizedString(key, comment: "")
    }
    var imageName: String {
        return "search-\(self.rawValue)"
    }
    var usesPriority: Bool {
        switch self {
        case .beverages:
            return false
        case .confectionery:
            return true
        default:
            return false
        }
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

    var searchAttributes: [String] {
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
            return ["regions", "valuePropositions", "application", "notes", "labelDeclaration", "selectionCriteria", "recommendedMaxUsage"]
        default:
            return []
        }
    }

    static let count: Int = {
        var max: Int = 0
        while let _ = ProductType(rawValue: max) { max += 1 }
        return max
    }()

    // MARK: Factory
    func productWith(dictionary: Dictionary<String, Any>) -> Product {
        switch self {
        case .beverages:
            return Beverage(dictionary)
        case .confectionery:
            return Confectionery(dictionary)
        default:
            return Beverage(dictionary)
        }
    }
    
    // MARK: Search
    func dropDownValuesFor(attribute: String, in searchCriteria: SearchCriteria) -> [String] {
        var criteria = searchCriteria
        criteria.toggleValueForAttribute(attribute, value: SearchCriteria.ALL())
        let products = productsWithSearchCriteria(criteria)
        var values = propertyValues(attribute, in: products)
        values.insert(NSLocalizedString(SearchCriteria.ALL(), comment: ""), at: 0)
        return values
    }

    func productsWithSearchCriteria(_ searchCriteria: SearchCriteria) -> [Product] {
        let filtered = products.filter { return searchCriteria.matches($0) }
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
        return criteria.count == 1 && criteria.first == SearchCriteria.ALL()
    }
}

