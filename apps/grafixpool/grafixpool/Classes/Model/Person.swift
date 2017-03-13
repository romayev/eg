//
//  Person.swift
//  grafixpool
//
//  Created by Alex Romayev on 3/12/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import CoreData

extension Person {
    static func defaultPerson(_ context: NSManagedObjectContext) -> Person? {
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        fetchRequest.fetchLimit = 1
        do {
            let person = try context.fetch(fetchRequest)
            return person.first
        } catch {
            fatalError("Failed to fetch default person: \(error)")
        }
    }
}
