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
        case slides, project, inDate, reminder, outDate, confidentiality, jobType, comments
        var editCellType: EGEditCellType {
            switch self {
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
                return [IndexPath(item: CellMapping.reminder.rawValue, section: 0), IndexPath(item: CellMapping.outDate.rawValue, section: 0)]
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
    
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var nextBarButtonItem: UIBarButtonItem!
    @IBOutlet var deleteBarButtonItem: UIBarButtonItem!

    let editingContext = DataStore.store.editingContext
    var booking: Booking!

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        nextBarButtonItem.title = NSLocalizedString("next", comment: "")
        deleteBarButtonItem.title = NSLocalizedString("cancel-booking", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (booking == nil) {
            booking = Booking(context: editingContext)
        } else {
            booking = editingContext.object(with: booking.objectID) as! Booking
        }

        if booking.isInserted {
            toolbar.isHidden = true
            navigationItem.title = NSLocalizedString("add-booking", comment: "")
        } else {
            navigationItem.title = NSLocalizedString("edit-booking", comment: "")
        }
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(watchOS) || os(tvOS))
            DataStore.store.save(editing: editingContext)
            self.dismiss(animated: true, completion: nil)
        #else
            if booking.isInserted {
                send(email: .add)
            } else if (editingContext.hasChanges) {
                send(email: .update)
            }
        #endif
    }

    @IBAction func deleteBooking(_ sender: UIBarButtonItem) {
        #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(watchOS) || os(tvOS))
            editingContext.delete(booking)
            DataStore.store.save(editing: editingContext)
            self.dismiss(animated: true, completion: nil)
        #else
            send(email: .cancel)
        #endif
    }

    // MARK: EGEditTableViewController
    override var count: Int { return BookingTableCellType.count }

    override var cellType: EGEditCellType {
        guard let activeRow = activePath?.row else  {
            fatalError("ERROR: Active cell undefined")
        }
        guard let mapping = CellMapping(rawValue: activeRow) else {
            fatalError("ERROR: Unable to find mapping for row \(activeRow)")
        }
        return mapping.editCellType
    }

    override func cell(atAdjusted indexPath: IndexPath) -> UITableViewCell {
        guard let mapping = CellMapping(rawValue: indexPath.row) else {
            fatalError("ERROR: Unable to find mapping for row \(indexPath.row)")
        }
        switch mapping {
        case .inDate, .outDate:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as! DateCell
            let type = bookingTableCellType(forAdjusted: indexPath)
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
            let type = bookingTableCellType(forAdjusted: indexPath)
            cell.textLabel?.text = type.localizedName
            cell.detailTextLabel?.text = self.description(forRow: indexPath.row)
            return cell
        }
    }

    // MARK: EGPickerEditCellDelegate
    override var itemsForEditCell: [String]? {
        guard let activeRow = activePath?.row else  {
            preconditionFailure("ERROR: Active cell undefined")
        }
        if let mapping = CellMapping(rawValue: activeRow) {
            return mapping.values(withBooking: booking, in: editingContext)
        }
        return nil
    }

    override var selectedItemsForEditCell: [String]? {
        guard let activeRow = activePath?.row else  {
            preconditionFailure("ERROR: Active cell undefined")
        }
        if let mapping = CellMapping(rawValue: activeRow) {
            switch mapping {
            case .jobType:
                if booking.jobTypeValues.count > 0 {
                    return booking.jobTypeValues
                }
            default:
                if let value = mapping.value(withBooking: booking) {
                    return [value]
                }
            }
        }
        return nil
    }

    override func editCellDidSelectValue(_ value: String, at index: Int) {
        guard let activeRow = activePath?.row else  {
            preconditionFailure("ERROR: Active cell undefined")
        }
        if let mapping = CellMapping(rawValue: activeRow) {
            mapping.processDidSelectValue(value, at: index, booking: booking)
        }

        tableView.reloadRows(at: [activePath!, editorPath!], with: .automatic)
    }

    override func editCellDidCollapse(at indexPath: IndexPath) {
        if let mapping = CellMapping(rawValue: indexPath.row) {
            if let indexPaths = mapping.indexPathsForDependentMappings {
                let adjusted = indexPaths.map { adjustedPath(forIndexPath: $0) }
                tableView.reloadRows(at: adjusted, with: .automatic)
            }
        }
    }

    // MARK: EGAddPickerEditCellDelegate
    override func editCellDidAdd(value: String) {
        let project = Project(context: editingContext)
        project.code = value
        booking.project = project
        project.addToBookings(booking)
        if let editorPath = editorPath {
            tableView.reloadRows(at: [activePath!, editorPath], with: .automatic)
        }
    }

    // MARK: EGDatePickerEditCellDelegate
    override var dateForEditCell: Date {
        get {
            guard let activePath = activePath else  {
                preconditionFailure("ERROR: Active cell undefined")
            }
            let type = bookingTableCellType(forAdjusted: activePath)
            assert(type == .inDate || type == .outDate, "Unexpected cell typefor row: \(activePath.row)")

            var result = Date().addingTimeInterval(3600 * 8)
            switch type {
            case .inDate:
                if let date = booking.inDate {
                    return date as Date
                }
            case .outDate:
                if let date = booking.outDate {
                    result = date as Date
                }
            default: break
            }

            return result
        }
        set {
            guard let activePath = activePath else  {
                preconditionFailure("ERROR: Active cell undefined")
            }
            let type = bookingTableCellType(forAdjusted: activePath)
            assert(type == .inDate || type == .outDate, "Unexpected cell typefor row: \(activePath.row)")
            switch type {
            case .inDate:
                booking.inDate = NSDate(timeIntervalSinceReferenceDate: newValue.timeIntervalSinceReferenceDate)
                if (booking.outDate as! Date) < (booking.inDate as! Date) {
                    booking.outDate = booking.inDate
                }
            case .outDate:
                booking.outDate = NSDate(timeIntervalSinceReferenceDate: newValue.timeIntervalSinceReferenceDate)
            default: break
            }
            tableView.reloadRows(at: [activePath], with: .automatic)
        }
    }

    // MARK: EGNotesEditCellDelegate
    override var notesForEditCell: String? {
        get {
            return booking.notes
        }
        set {
            booking.notes = newValue
            tableView.reloadRows(at: [activePath!], with: .none)
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

    private func bookingTableCellType(forAdjusted indexPath: IndexPath) -> BookingTableCellType {
        guard let type = BookingTableCellType(rawValue: indexPath.row) else {
            fatalError("Unable to get BookingTableCellType for row \(indexPath.row)")
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

        switch result {
        case .sent:
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: NSLocalizedString(NSLocalizedString("ok", comment: ""), comment: ""), style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(ok)
            present(alertController, animated: true, completion: nil)
        default: break
        }
    }

    private func send(email: BookingEmail) {
        let mailComposeViewController = configuredMailComposeViewController(email: email)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: {
                switch email {
                case .add:
                    BookingNotification.add.processNotification(for: self.booking)
                case .update:
                    BookingNotification.update.processNotification(for: self.booking)
                case .cancel:
                    BookingNotification.cancel.processNotification(for: self.booking)
                    self.editingContext.delete(self.booking)
                }
                DataStore.store.save(editing: self.editingContext)

            })
        } else {
            self.showSendMailErrorAlert()
        }
    }

    private func configuredMailComposeViewController(email: BookingEmail) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self

        let message = email.bookingMessage(with: booking)
        mailComposerVC.setToRecipients(message.recipients)
        mailComposerVC.setSubject(message.subject)
        mailComposerVC.setMessageBody(message.body, isHTML: false)

        return mailComposerVC
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

struct BookingMessage {
    let recipients = [NSLocalizedString("booking.email.recipient", comment: "")]
    var subject: String
    var body: String

    init(subject: String, body: String) {
        self.subject = subject
        self.body = body
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
