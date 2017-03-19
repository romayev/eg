//
//  ProductType.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/20/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

enum ProductType: String {
    case battersAndBreadings, beverages, carrageenan, confectionery, creamySalad, hydrocolloids, meat, processedCheese, tomatoBasedSauses, yogurt

    var localizedName: String {
        return NSLocalizedString(rawValue, comment: "")
    }
    var imageName: String {
        return "search-\(rawValue)"
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

    static let all = [ProductType.battersAndBreadings, ProductType.beverages, ProductType.carrageenan, ProductType.confectionery, ProductType.creamySalad, ProductType.hydrocolloids,
                      ProductType.meat, ProductType.processedCheese, ProductType.tomatoBasedSauses, ProductType.yogurt]
    static var count: Int { return all.count }

    // MARK: Factory
    func product(with dictionary: Dictionary<String, Any>) -> Product {
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
    func dropDownValues(for attribute: String, in searchCriteria: SearchCriteria) -> [String] {
        var criteria = searchCriteria
        criteria.toggleValueForAttribute(attribute, value: SearchCriteria.ALL())
        let products = self.products(with: criteria)
        var values = propertyValues(attribute, in: products)
        values.insert(NSLocalizedString(SearchCriteria.ALL(), comment: ""), at: 0)
        return values
    }

    func products(with searchCriteria: SearchCriteria) -> [Product] {
        let filtered = products.filter { return searchCriteria.matches($0) }
        let unique = Array(Set(filtered))

        let priority: SortDescriptor<Product> = {
            if let priority1 = $0.priority {
                if let priority2 = $1.priority {
                    return priority1 < priority2
                }
            }
            return false
        }
        let name: SortDescriptor<Product> = { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending  }
        let sortColumns: SortDescriptor<Product> = combine(sortDescriptors: [priority, name])
        return unique.sorted(by: sortColumns)
    }

    func highPriorityProducts(in products: [Product]) -> [Product] {
        guard let highestPriority = products.first?.priority else {
            preconditionFailure("No priority or products")
        }

        let result = products.filter { $0.priority == highestPriority }
        if result.count < 5 {
            return Array(products.prefix(5))
        } else {
            return result
        }
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

