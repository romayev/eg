//
//  Confectionery.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/12/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

class Confectionery : Product {
    let application : String?
    let selectionCriteria : String?
    let suggestedUsageLevelInFormulations : String?
    let recommendedMaxUsage : String?

    override var displayAttributes: [String] {
        return ["regions", "valuePropositions", "applications", "notes", "labelDeclaration", "selectionCriteria", "recommendedMaxUsage"]
    }

    override init(_ dictionary : Dictionary<String, Any>) {
        application = dictionary["application"] as? String
        selectionCriteria = dictionary["selectionCriteria"] as? String
        suggestedUsageLevelInFormulations = dictionary["suggestedUsageLevelInFormulations"] as? String
        recommendedMaxUsage = dictionary["recommendedMaxUsage"] as? String
        super.init(dictionary)
    }

    override func products() -> [Product] {
        return DataManager.manager.confectionery
    }
}
