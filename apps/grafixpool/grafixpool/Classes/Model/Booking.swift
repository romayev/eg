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
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        inDate = NSDate()
        outDate = NSDate()
        confidentiality = Confidentiality.defaultValue.coreDataValue
        slideCount = 10
        project = Project.last(context: managedObjectContext!)
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

extension Booking {
    static func last(_ context: NSManagedObjectContext) -> Booking? {
        let fetchRequest: NSFetchRequest<Booking> = Booking.fetchRequest()
        let inDateSort = NSSortDescriptor(key: "inDate", ascending: false)
        fetchRequest.sortDescriptors = [inDateSort]
        fetchRequest.fetchLimit = 1
        do {
            let records = try context.fetch(fetchRequest)
            return records.first
        } catch {
            fatalError("Failed to fetch job types: \(error)")
        }
    }
}

enum Confidentiality: Int {
    case level1 = 1, level2, level3
    var localizedName: String {
        switch self {
        case .level1:
            return NSLocalizedString("confidentiality.level1", comment: "")
        case .level2:
            return NSLocalizedString("confidentiality.level2", comment: "")
        case .level3:
            return NSLocalizedString("confidentiality.level3", comment: "")
        }
    }
    var coreDataValue: Int16 {
        return Int16(rawValue)
    }

    static let defaultValue = Confidentiality.level2
    static let all = [Confidentiality.level1, Confidentiality.level2, Confidentiality.level3]
    static let localizedValues: [String] = {
        var values = [String]()
        for type in Confidentiality.all {
            values.append(type.localizedName)
        }
        return values
    }()

    init?(coreDataValue: Int16) {
        self.init(rawValue: Int(coreDataValue))
    }
}
