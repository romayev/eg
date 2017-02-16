//
//  Beverage.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/10/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

class Beverage : Product {
    let segment: String?
    let base: String?
    let starchUseLabel: String?
    let fatContent: String?
    let proteinContent: String?
    let features: String?
    let productDescription: String?

    override var products: [Product] {
        return DataManager.manager.beverages
    }

    override var displayAttributes: [String] {
        return ["base", "labelDeclaration", "regions", "starchUseLabel", "valuePropositions", "fatContent", "proteinContent", "features"]
    }

    override init(_ dictionary: Dictionary<String, Any>) {
        segment = dictionary["segment"] as? String
        base = dictionary["base"] as? String
        starchUseLabel = dictionary["starchUseLabel"] as? String
        fatContent = dictionary["fatContent"] as? String
        proteinContent = dictionary["proteinContent"] as? String
        features = dictionary["features"] as? String
        productDescription = dictionary["productDescription"] as? String
        super.init(dictionary)
    }
}
