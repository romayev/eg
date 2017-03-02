//
//  Booking.swift
//  grafixpool
//
//  Created by Alex Romayev on 2/27/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import CoreData

extension Booking {
    static func create(context: NSManagedObjectContext) -> Booking {
        return NSEntityDescription.insertNewObject(forEntityName: "Booking", into: context) as! Booking
    }
}

extension Task {
    static func create(context: NSManagedObjectContext) -> Task {
        return NSEntityDescription.insertNewObject(forEntityName: "Task", into: context) as! Task
    }
}
