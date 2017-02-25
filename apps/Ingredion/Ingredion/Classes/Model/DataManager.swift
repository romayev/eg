//
//  DataManager.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/10/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

final class DataManager {
    static let manager = DataManager()

    lazy var beverages = DataManager.load(.beverages)
    lazy var confectionery = DataManager.load(.confectionery)

    static func load(_ productType: ProductType) -> [Product] {
        var r = [Product]()
        if let path = Bundle.main.path(forResource: productType.module, ofType: "plist") {
            let plist = FileManager.default.contents(atPath: path)!
            do {
                var format = PropertyListSerialization.PropertyListFormat.xml
                let array = try PropertyListSerialization.propertyList(from: plist, options: .mutableContainersAndLeaves, format: &format) as! [Dictionary<String, Any>]
                for dict in array {
                    let item = productType.productWith(dictionary: dict)
                    r.append(item)
                }
            } catch {
                print("Error reading plist for \(productType.module).plist: \(error)")
            }
        }
        return r
    }
}