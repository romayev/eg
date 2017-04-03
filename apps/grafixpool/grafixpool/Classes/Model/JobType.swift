//
//  JobType.swift
//  grafixpool
//
//  Created by Alex Romayev on 3/4/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import CoreData
import EGKit

extension JobType {
    static func createJobTypes(_ context: NSManagedObjectContext) {
        for (index, _) in JobType.Category.all.enumerated() {
            let record = JobType(context: context)
            record.id = Int16(index + 1)
        }
    }
    static func all(_ context: NSManagedObjectContext) -> Array<JobType> {
        let fetchRequest: NSFetchRequest<JobType> = JobType.fetchRequest()
        do {
            let all = try context.fetch(fetchRequest)
            return all
        } catch {
            fatalError("Failed to fetch job types: \(error)")
        }
    }

    static func isLoaded(_ context: NSManagedObjectContext) -> Bool {
        let fetchRequest: NSFetchRequest<JobType> = JobType.fetchRequest()
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            fatalError("Failed to fetch job types: \(error)")
        }
    }

    static func jobType(forIndex index: Int, context: NSManagedObjectContext = DataStore.store.viewContext) -> JobType {
        let fetchRequest: NSFetchRequest<JobType> = JobType.fetchRequest()
        let predicate = NSPredicate(format: "id == \(index)")
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        do {
            let records = try context.fetch(fetchRequest)
            return records.first!
        } catch {
            fatalError("Failed to fetch job types: \(error)")
        }
    }
}

extension JobType {
    enum Category: Int {
        case adjustToSMC = 1, improve, createVersion, finalCheck, translation
        var localizedName: String {
            switch self {
            case .adjustToSMC:
                return "job-type.adjust-to-smc".localized
            case.improve:
                return "job-type.improve".localized
            case .createVersion:
                return "job-type.create-version".localized
            case .finalCheck:
                return "job-type.final-check".localized
            case .translation:
                return "job-type.translation".localized
            }
        }
        var coreDataValue: Int16 {
            return Int16(rawValue)
        }

        static let defaultValue = Category.adjustToSMC
        static let all = [Category.adjustToSMC, Category.improve, Category.createVersion, Category.finalCheck, Category.translation]
        static let localizedValues: [String] = {
            var values = [String]()
            for type in Category.all {
                values.append(type.localizedName)
            }
            return values
        }()

        init?(coreDataValue: Int16) {
            self.init(rawValue: Int(coreDataValue))
        }
    }
}
