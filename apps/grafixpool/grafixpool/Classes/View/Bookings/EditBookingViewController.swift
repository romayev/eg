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
import MessageUI

class EditBookingViewController: EGEditTableViewController, MFMailComposeViewControllerDelegate {
    enum CellMapping: Int {
        case slides, project, inDate, outDate, confidentiality, jobType, comments
        var editCellType: EGEditCellType {
            switch self {
            case .slides:
                return .picker
            case .inDate, .outDate:
                return .date
            case .project:
                return .dropDownAdd
            case .confidentiality, .jobType:
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
        func processDidSelectValue(_ value: String, at index: Int, booking: Booking) {
            let idx = Int16(index) + 1
            switch self {
            case .slides: booking.slideCount = Int16(index)
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
        #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(watchOS) || os(tvOS))
            self.dismiss(animated: true, completion: nil)
        #else
            sendEmail()
        #endif
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
        guard let mapping = CellMapping(rawValue: row) else {
            fatalError("ERROR: Unable to find mapping for row \(row)")
        }
        switch mapping {
        case .inDate, .outDate:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as! DateCell
            let type = bookingTableCellType(forRow: indexPath.row)
            cell.titleLabel?.text = type.localizedName
            switch mapping {
            case .inDate:
                cell.display(date: booking.inDate!, singleZone: isCurrentTimeZoneCET())
            case .outDate:
                cell.display(date: booking.outDate!, singleZone: isCurrentTimeZoneCET())
            default: break
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            let type = bookingTableCellType(forRow: indexPath.row)
            cell.textLabel?.text = type.localizedName
            cell.detailTextLabel?.text = self.description(forRow: row)
            return cell
        }
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
        if let mapping = CellMapping(rawValue: activeRow) {
            mapping.processDidSelectValue(value, at: index, booking: booking)
        }

        tableView.reloadRows(at: [activeCellPath!, editorPath!], with: .automatic)
    }

    // MARK: EGAddPickerEditCellDelegate
    override func editCellDidAdd(value: String) {
        let project = Project(context: editingContext)
        project.code = value
        booking.project = project
        project.addToBookings(booking)
    }

    // MARK: EGDatePickerEditCellDelegate
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

    // MARK: EGNotesEditCellDelegate
    override var notesForEditCell: String? {
        get {
            return booking.notes
        }
        set {
            booking.notes = newValue
            tableView.reloadRows(at: [activeCellPath!], with: .none)
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

    // MARK: MailComposer
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        let title = NSLocalizedString("email.alert.title", comment: "")
        var message = NSLocalizedString("email.alert.message.success", comment: "")
        if error != nil {
            let m = NSLocalizedString("email.alert.message.error", comment: "")
            message = "\(m) \(error)"
        }

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLocalizedString(NSLocalizedString("ok", comment: ""), comment: ""), style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(ok)
        present(alertController, animated: true, completion: nil)
    }

    private func sendEmail() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }

    private func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self

        mailComposerVC.setToRecipients([NSLocalizedString("email.booking.recipient", comment: "")])
        mailComposerVC.setSubject(NSLocalizedString("email.booking.subject-new", comment: ""))
        mailComposerVC.setMessageBody(emailBody(), isHTML: false)

        return mailComposerVC
    }

    private func emailBody() -> String {
        guard let project = booking.project?.code else {
            preconditionFailure()
        }
        guard let inDate = booking.inDate else {
            preconditionFailure()
        }
        guard let outDate = booking.outDate else {
            preconditionFailure()
        }
        let body = "\(project)\n\(inDate)\n\(outDate)"
        return body
    }

    private func showSendMailErrorAlert() {
        let title = NSLocalizedString("error", comment: "")
        let message = NSLocalizedString("email.alert.unable-to-send-mail", comment: "")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLocalizedString(NSLocalizedString("ok", comment: ""), comment: ""), style: .default, handler: nil)
        alertController.addAction(ok)
        present(alertController, animated: true, completion: nil)
    }
}

class DateCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var topDateLabel: UILabel!
    @IBOutlet var bottomDateLabel: UILabel!

    func display(date: NSDate, singleZone: Bool) {
        if singleZone {
            topDateLabel.isHidden = true
            bottomDateLabel.isHidden = true
            dateLabel.isHidden = false
            dateLabel.text = date.format
        } else {
            topDateLabel.isHidden = false
            bottomDateLabel.isHidden = false
            dateLabel.isHidden = true
            topDateLabel.text = date.format
            bottomDateLabel.text = date.inCETTimeZone.formatCET
        }
    }
}
