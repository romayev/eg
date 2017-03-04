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

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        inDate = NSDate()
        outDate = NSDate()
        confidentiality = Confidentiality.defaultValue.coreDataValue
    }

    var jobTypeCategories: [JobType.Category] {
        guard let jobTypes = jobTypes else {
            preconditionFailure("No job types in Booking")
        }
        var result: [JobType.Category] = []
        let array: [JobType] = jobTypes.allObjects as! [JobType]

        for jobType: JobType in array {
            result.append(JobType.Category(rawValue: Int(jobType.id))!)
        }
        return result
    }

    var jobTypeValues: [String] {
        let jobTypes = jobTypeCategories
        return jobTypes.map { $0.localizedName }
    }

    func add(jobType: JobType) {
        addToJobTypes(jobType)
        jobType.addToBookings(self)
    }
}

extension JobType {
    static let entityName = "JobType"
    static func create(context: NSManagedObjectContext) -> JobType {
        return NSEntityDescription.insertNewObject(forEntityName: JobType.entityName, into: context) as! JobType
    }

    static func all(context: NSManagedObjectContext) -> Array<JobType> {
        let fetchRequest: NSFetchRequest<JobType> = JobType.fetchRequest()
        do {
            let all = try context.fetch(fetchRequest)
            return all
        } catch {
            fatalError("Failed to fetch job types: \(error)")
        }
    }

    static func isLoaded(context: NSManagedObjectContext) -> Bool {
        let fetchRequest: NSFetchRequest<JobType> = JobType.fetchRequest()
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            fatalError("Failed to fetch job types: \(error)")
        }
    }

    static func jobType(forIndex index: Int, context: NSManagedObjectContext) -> JobType {
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
                return NSLocalizedString("job-type.adjust-to-smc", comment: "")
            case.improve:
                return NSLocalizedString("job-type.improve", comment: "")
            case .createVersion:
                return NSLocalizedString("job-type.create-version", comment: "")
            case .finalCheck:
                return NSLocalizedString("job-type.final-check", comment: "")
            case .translation:
                return NSLocalizedString("job-type.translation", comment: "")
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
