//
//  Booking.swift
//  grafixpool
//
//  Created by Alex Romayev on 2/27/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension Booking {
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        bookingID = createBookingID() as String

        if let nextHour = nextHourDate()?.timeIntervalSinceReferenceDate {
            if let last = Booking.last(managedObjectContext!) {
                confidentiality = last.confidentiality
                reminder = last.reminder
                inDate = NSDate(timeIntervalSinceReferenceDate: nextHour).addingTimeInterval(reminder)
            } else {
                confidentiality = Confidentiality.defaultValue.coreDataValue
                reminder = 3600
                inDate = NSDate(timeIntervalSinceReferenceDate: nextHour)
            }
            outDate = inDate
        }
        project = Project.last(context: managedObjectContext!)
    }
    private func nextHourDate() -> Date? {
        let calendar = NSCalendar.current
        let comps = calendar.dateComponents([.year, .month, .day, .hour], from: Date())
        let date = calendar.date(from: comps)
        var components = DateComponents()
        components.hour = 1
        return calendar.date(byAdding: components, to: date!)
    }

    var confidentialityType: Confidentiality {
        guard let type = Confidentiality(coreDataValue: confidentiality) else {
            fatalError("Unable to create Confidentiality enum with \(confidentiality)")
        }
        return type
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

    private func createBookingID() -> String {
        let df = DateFormatter()
        df.dateFormat = "YYYYMMddhhmmss"
        let string = df.string(from: created as! Date)
        let random = arc4random_uniform(9)
        return "\(string)\(random)"
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
            fatalError("Failed to last booking: \(error)")
        }
    }
    static func with(_ bookingID: String, context: NSManagedObjectContext) -> Booking? {
        let fetchRequest: NSFetchRequest<Booking> = Booking.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "bookingID = %@", bookingID)
        fetchRequest.fetchLimit = 1
        do {
            let records = try context.fetch(fetchRequest)
            return records.first
        } catch {
            fatalError("Failed to fetch booking with bookingID: \(error)")
        }
    }
}

enum Confidentiality: Int {
    case restricted = 1, confidential, strictlyConfidential
    var localizedName: String {
        switch self {
        case .restricted:
            return NSLocalizedString("confidentiality.restricted", comment: "")
        case .confidential:
            return NSLocalizedString("confidentiality.confidential", comment: "")
        case .strictlyConfidential:
            return NSLocalizedString("confidentiality.strictly-confidential", comment: "")
        }
    }
    var coreDataValue: Int16 {
        return Int16(rawValue)
    }

    static let defaultValue = Confidentiality.confidential
    static let all = [Confidentiality.restricted, Confidentiality.confidential, Confidentiality.strictlyConfidential]
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

struct Reminder {
    var date: Date
    var difference: Double
    var fireDate: Date {
        return date.addingTimeInterval(Double(-difference))
    }

    init(difference: Double, date: Date) {
        self.difference = difference
        self.date = date
    }
    
    var localizedName: String {
        if difference == 0 {
            return NSLocalizedString("none", comment: "")
        } else {
            let df = DateFormatter()
            df.timeStyle = .short
            let fireDate = df.string(from: self.fireDate)
            let format = NSLocalizedString("hours-before", comment: "")
            let hoursBefore = String.localizedStringWithFormat(format, Int(difference / 3600))
            return "\(hoursBefore) \(fireDate)"
        }
    }
    static func localizedValues(for date: Date) -> [String] {
        let now = Date()
        var all: [Reminder] = [Reminder]()
        var index = 0.0
        var reminder: Reminder
        repeat {
            let difference = index * 3600.0
            reminder = Reminder(difference: difference, date: date)
            all.append(reminder)
            index += 1
        } while reminder.fireDate > now && index < 5
        var values = [String]()
        for type in all {
            values.append(type.localizedName)
        }
        return values
    }
}
