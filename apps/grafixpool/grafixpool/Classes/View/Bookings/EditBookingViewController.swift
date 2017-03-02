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
    let editingContext = DataStore.store.editingOjbectContext
    var booking: Booking!

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (booking == nil) {
            booking = Booking.create(context: editingContext)
            booking.task = Task.create(context: editingContext)
        }
        precondition(booking != nil, "Booking must exist at this point")

        if booking.isInserted {
            navigationItem.title = NSLocalizedString("add-booking", comment: "")
        } else {
            navigationItem.title = NSLocalizedString("edit-booking", comment: "")
        }
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        DataStore.store.saveContext(editingContext)
        dismiss(animated: true, completion: nil)
    }

    // MARK: EGEditTableViewController
    override var count: Int { return BookingTableCellType.count }

    override var cellType: EGEditCellType {
        guard let activeRow = activeCellPath?.row else  {
            fatalError("ERROR: Active cell undefined")
        }
        return editCellType(forRow: activeRow)
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
        switch activeRow {
        case 0:
            return JobType.localizedValues
        case 3:
            return Layout.localizedValues
        case 4:
            return (0...100).map { String($0) }
        case 5:
            return AspectRatio.localizedValues
        case 6:
            return Confidentiality.localizedValues
        default:
            return nil
        }
    }

    override var selectedItemsForEditCell: [String]? {
        guard let activeRow = activeCellPath?.row else  {
            preconditionFailure("ERROR: Active cell undefined")
        }
        if let value = value(forRow: activeRow) {
            return [value]
        } else {
            return nil
        }
    }

    override func editCellDidSelectValue(_ value: String, at index: Int) {
        guard let activeRow = activeCellPath?.row else  {
            preconditionFailure("ERROR: Active cell undefined")
        }
        guard let task = booking.task else {
            preconditionFailure("No task found for booking")
        }
        let idx = Int16(index) + 1
        switch activeRow {
        case 0: task.type = idx
        case 3: task.layout = idx
        case 4: task.slideCount = idx - 1
        case 5: task.aspectRatio = idx
        case 6: task.confidentiality = idx
        default: break
        }
        tableView.reloadRows(at: [activeCellPath!], with: .automatic)
    }

    // MARK: EGDatePickerEditCellDelegate - vars
    override var dateForEditCell: Date {
        get {
            guard let activeRow = activeCellPath?.row else  {
                preconditionFailure("ERROR: Active cell undefined")
            }
            let type = bookingTableCellType(forRow: activeRow)
            assert(type == .due || type == .preferred, "Unexpected cell typefor row: \(activeCellPath?.row)")

            var result = Date().addingTimeInterval(3600 * 8)
            switch type {
            case .due:
                if let date = booking.due {
                    return date.date
                }
            case .preferred:
                if let date = booking.preferred {
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
            assert(type == .due || type == .preferred, "Unexpected cell typefor row: \(activeCellPath?.row)")
            switch type {
            case .due:
                booking.due = NSDate(timeIntervalSinceReferenceDate: newValue.timeIntervalSinceReferenceDate)
            case .preferred:
                booking.preferred = NSDate(timeIntervalSinceReferenceDate: newValue.timeIntervalSinceReferenceDate)
            default: break
            }
            tableView.reloadRows(at: [activeCellPath!], with: .automatic)
        }
    }

    // MARK: Helpers
    private func description(forRow row: Int) -> String {
        if let value = value(forRow: row) {
            return value
        } else {
            return "--"
        }
    }

    private func value(forRow row: Int) -> String? {
        guard let task = booking.task else {
            preconditionFailure("No task found for booking")
        }
        switch row {
        case 0:
            if let type = JobType(rawValue: Int(task.type)) {
                return type.localizedName
            } else {
                return nil
            }
        case 1:
            return booking.due != nil ? (booking.due?.format)! : nil
        case 2:
            return booking.preferred != nil ? (booking.preferred?.format)! : nil
        case 3:
            if let layout = Layout(rawValue: Int(task.layout)) {
                return layout.localizedName
            } else {
                return nil
            }
        case 4:
            if task.slideCount == 0 {
                return nil
            } else {
                return String(task.slideCount)
            }
        case 5:
            if let aspectRatio = AspectRatio(rawValue: Int(task.aspectRatio)) {
                return aspectRatio.localizedName
            } else {
                return nil
            }
        case 6:
            if let confidentiality = Confidentiality(rawValue: Int(task.confidentiality)) {
                return confidentiality.localizedName
            } else {
                return nil
            }
        default:
            return nil
        }
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

    private func editCellType(forRow row: Int) -> EGEditCellType {
        switch row {
        case 1, 2:
            return .date
        case 4:
            return .picker
        default:
            return .dropDown
        }
    }
}
