//
//  SearchItem.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/9/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

class SearchItem {
    let itemID: Int?
    let title: String?

    static var __regions: [String] = []

    init(dictionary: Dictionary<String, Any>) {
        itemID = dictionary["id"] as? Int
        title = dictionary["title"] as? String
    }

    static func regions() -> [String] {
        if (__regions.isEmpty) {
            return __regions;
        }
        return __regions;
    }
}
