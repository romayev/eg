//
//  DataManager.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/10/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

class DataManager {
    static let manager = DataManager()

    lazy var beverages = DataManager.load("beverages") { (dict) -> Product in Beverage(dict) }
    lazy var confectionery = DataManager.load("confectionery") { (dict) -> Product in Confectionery(dict) }

    static func load(_ product: String, instance: (_ d: Dictionary<String, Any>) -> Product) -> [Product] {
        var r = [Product]()
        if let path = Bundle.main.path(forResource: product, ofType: "plist") {
            let plist = FileManager.default.contents(atPath: path)!
            do {
                var format = PropertyListSerialization.PropertyListFormat.xml
                let array = try PropertyListSerialization.propertyList(from: plist, options: .mutableContainersAndLeaves, format: &format) as! [Dictionary<String, Any>]
                for dict in array {
                    let item = instance(dict)
                    r.append(item)
                }
            } catch {
                print("Error reading plist for \(product).plist: \(error)")
            }
        }
        return r
    }
}
