//
//  BookingTableCellType.swift
//  grafixpool
//
//  Created by Alex Romayev on 2/27/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import CoreData
import EGKit

enum BookingTableCellType: Int {
    case person, slides, project, inDate, reminder, outDate, confidentiality, jobType, comments
    
    var name: String {
        switch self {
        case .person: return "person"
        case .slides: return "slides"
        case .project: return "project"
        case .inDate: return "in"
        case .outDate: return "out"
        case .reminder: return "notification"
        case .confidentiality: return "confidentiality"
        case .jobType: return "job-type"
        case .comments: return "notes"
        }
    }
    var localizedName: String {
        return NSLocalizedString("booking.edit." + name, comment: "")
    }
    static let count: Int = {
        var max: Int = 0
        while let _ = BookingTableCellType(rawValue: max) { max += 1 }
        return max
    }()

    static let values: [BookingTableCellType] = {
        var values = [BookingTableCellType]()
        var max: Int = 0
        while let type = BookingTableCellType(rawValue: max) {
            max += 1
            values.append(type)
        }
        return values
    }()

    static let localizedValues: [String] = {
        var values = [String]()
        var max: Int = 0
        while let type = BookingTableCellType(rawValue: max) {
            max += 1
            values.append(type.localizedName)
        }
        return values
    }()

    var editCellType: EGEditCellType {
        switch self {
        case .person:            
            fatalError("Person cell is not editable")
        case .slides:
            return .picker
        case .inDate, .outDate:
            return .date
        case .project:
            return .dropDownAdd
        case .reminder, .confidentiality, .jobType:
            return .dropDown
        case .comments:
            return .notes
        }
    }
    var indexPathsForDependentMappings: [IndexPath]? {
        switch self {
        case .inDate:
            return [IndexPath(item: BookingTableCellType.reminder.rawValue, section: 0), IndexPath(item: BookingTableCellType.outDate.rawValue, section: 0)]
        default:
            return nil
        }
    }
    func values(withBooking booking: Booking, in context: NSManagedObjectContext) -> [String] {
        switch self {
        case .slides: return (0...100).map { String($0) }
        case .project: return Project.recentProjectNames(context)
        case .reminder: return Reminder.localizedValues(for: booking.inDate as! Date)
        case .confidentiality: return Confidentiality.localizedValues
        case .jobType: return JobType.Category.localizedValues
        default: fatalError("\(self) type does not support multiple values")
        }
    }
    func value(withBooking booking: Booking) -> String? {
        switch self {
        case .person:
            return booking.person?.formatted
        case .slides:
            if booking.slideCount == 0 {
                return nil
            } else {
                return String(booking.slideCount)
            }
        case .project:
            if let code = booking.project?.code {
                return code == "default" ? NSLocalizedString("default-project", comment: "") : code
            } else {
                fatalError("Booking does not have a project")
            }
        case .inDate:
            return (booking.inDate?.format)!
        case .outDate:
            return (booking.outDate?.format)!
        case .reminder:
            let reminder = Reminder(difference: booking.reminder, date: booking.inDate as! Date)
            return reminder.localizedName
        case .confidentiality:
            if let confidentiality = Confidentiality(coreDataValue: booking.confidentiality) {
                return confidentiality.localizedName
            } else {
                return nil
            }
        case .jobType:
            let values = booking.jobTypeValues
            return values.count > 0 ? booking.jobTypeValues.joined(separator: ", ") : nil
        case .comments:
            return booking.notes
        }
    }

    func processDidSelectValue(_ value: String, at index: Int, booking: Booking) {
        let idx = Int16(index) + 1
        switch self {
        case .slides: booking.slideCount = Int16(index)
        case .reminder: booking.reminder = Double(index * 3600)
        case .confidentiality: booking.confidentiality = idx
        case .jobType:
            let jobType = JobType.jobType(forIndex: index + 1, context: booking.managedObjectContext!)
            guard let jobTypes = booking.jobTypes else {
                fatalError("Booking doesn't have job types")
            }
            if (jobTypes.contains(jobType)) {
                booking.removeFromJobTypes(jobType)
            } else {
                booking.addToJobTypes(jobType)
            }
        case .project: break
        default: fatalError("Not a selectable cell type")
        }
    }
}
