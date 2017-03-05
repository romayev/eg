//
//  EditBookingViewController.swift
//  grafixpool
//
//  Created by Alex Romayev on 2/26/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import UIKit
import EGKit
import CoreData

enum CellMapping: Int {
    case slides, project, inDate, outDate, confidentiality, jobType, comments
    var editCellType: EGEditCellType {
        switch self {
        case .slides:
            return .picker
        case .inDate, .outDate:
            return .date
        case .project, .confidentiality, .jobType:
            return .dropDown
        case .comments:
            return .notes
        }
    }
    func values(context: NSManagedObjectContext) -> [String] {
        switch self {
        case .slides: return (0...100).map { String($0) }
        case .project: return Project.recentProjectNames(context)
        case .confidentiality: return Confidentiality.localizedValues
        case .jobType: return JobType.Category.localizedValues
        default: fatalError("\(self) type does not support multiple values")
        }
    }
    func value(withBooking booking: Booking) -> String? {
        switch self {
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
}

extension NSDate {
    var date: Date {
        return Date(timeIntervalSinceReferenceDate: self.timeIntervalSinceReferenceDate)
    }
    var format: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        df.doesRelativeDateFormatting = true
        return df.string(from: self.date)
    }
}

class EditBookingViewController: EGEditTableViewController {
    let editingContext = DataStore.store.editingContext
    var booking: Booking!

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (booking == nil) {
            booking = Booking(context: editingContext)
        }

        if booking.isInserted {
            navigationItem.title = NSLocalizedString("add-booking", comment: "")
        } else {
            navigationItem.title = NSLocalizedString("edit-booking", comment: "")
        }
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        DataStore.store.save(editing: editingContext)
        dismiss(animated: true, completion: nil)
    }

    // MARK: EGEditTableViewController
    override var count: Int { return BookingTableCellType.count }

    override var cellType: EGEditCellType {
        guard let activeRow = activeCellPath?.row else  {
            fatalError("ERROR: Active cell undefined")
        }
        guard let mapping = CellMapping(rawValue: activeRow) else {
            fatalError("ERROR: Unable to find mapping for row \(activeRow)")
        }
        return mapping.editCellType
    }

    override func cellFor(_ row: Int, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let type = bookingTableCellType(forRow: indexPath.row)
        cell.textLabel?.text = type.localizedName
        cell.detailTextLabel?.text = self.description(forRow: row)
        return cell
    }

    // MARK: EGPickerEditCellDelegate
    override var itemsForEditCell: [String]? {
        guard let activeRow = activeCellPath?.row else  {
            preconditionFailure("ERROR: Active cell undefined")
        }
        if let mapping = CellMapping(rawValue: activeRow) {
            return mapping.values(context: editingContext)
        }
        return nil
    }

    override var selectedItemsForEditCell: [String]? {
        guard let activeRow = activeCellPath?.row else  {
            preconditionFailure("ERROR: Active cell undefined")
        }
        if (activeRow == 5) {
            if booking.jobTypeValues.count > 0 {
                return booking.jobTypeValues
            } else {
                return nil
            }
        }
        if let mapping = CellMapping(rawValue: activeRow) {
            if let value = mapping.value(withBooking: booking) {
                return [value]
            }
        }
        return nil
    }

    override func editCellDidSelectValue(_ value: String, at index: Int) {
        guard let activeRow = activeCellPath?.row else  {
            preconditionFailure("ERROR: Active cell undefined")
        }
        let idx = Int16(index) + 1
        switch activeRow {
            // FIXME: Case 0: project & case 5: job types
        case 4: booking.confidentiality = idx
        case 5:
            let jobType = JobType.jobType(forIndex: index + 1, context: editingContext)
            guard let jobTypes = booking.jobTypes else {
                fatalError("Booking doesn't have job types")
            }
            if (jobTypes.contains(jobType)) {
                booking.removeFromJobTypes(jobType)
            } else {
                booking.addToJobTypes(jobType)
            }
        default: break
        }
        
        tableView.reloadRows(at: [activeCellPath!, editorPath!], with: .automatic)
    }

    // MARK: EGDatePickerEditCellDelegate - vars
    override var dateForEditCell: Date {
        get {
            guard let activeRow = activeCellPath?.row else  {
                preconditionFailure("ERROR: Active cell undefined")
            }
            let type = bookingTableCellType(forRow: activeRow)
            assert(type == .inDate || type == .outDate, "Unexpected cell typefor row: \(activeCellPath?.row)")

            var result = Date().addingTimeInterval(3600 * 8)
            switch type {
            case .inDate:
                if let date = booking.inDate {
                    return date.date
                }
            case .outDate:
                if let date = booking.outDate {
                    result = date.date
                }
            default: break
            }

            return result
        }
        set {
            guard let activeRow = activeCellPath?.row else  {
                preconditionFailure("ERROR: Active cell undefined")
            }
            let type = bookingTableCellType(forRow: activeRow)
            assert(type == .inDate || type == .outDate, "Unexpected cell typefor row: \(activeCellPath?.row)")
            switch type {
            case .inDate:
                booking.inDate = NSDate(timeIntervalSinceReferenceDate: newValue.timeIntervalSinceReferenceDate)
            case .outDate:
                booking.outDate = NSDate(timeIntervalSinceReferenceDate: newValue.timeIntervalSinceReferenceDate)
            default: break
            }
            tableView.reloadRows(at: [activeCellPath!], with: .automatic)
        }
    }

    // MARK: Helpers
    private func description(forRow row: Int) -> String {
        if let mapping = CellMapping(rawValue: row) {
            if let value = mapping.value(withBooking: booking) {
                return value
            }
        }
    return "--"
    }

    private func bookingTableCellType(forRow row: Int) -> BookingTableCellType {
        var rawValue = row
        if let activeRow = activeCellPath?.row {
            if activeRow > row {
                rawValue += 1
            }
        }
        guard let type = BookingTableCellType(rawValue: rawValue) else {
            fatalError("Unable to get BookingTableCellType for rawValue \(rawValue)")
        }
        return type
    }

}
