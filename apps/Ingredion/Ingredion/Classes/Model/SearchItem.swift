//
//  SearchItem.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/9/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

struct SearchItem {
    let itemID: Int?
    let title: String?

    init(dictionary: Dictionary<String, Any>) {
        itemID = dictionary["id"] as? Int
        title = dictionary["title"] as? String
    }
}
