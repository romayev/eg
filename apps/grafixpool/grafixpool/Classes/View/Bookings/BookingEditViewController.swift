//
//  BookingEditViewController.swift
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

class BookingEditViewController: EGEditTableViewController, EGSegueHandlerType, PersonViewControllerDelegate, MFMailComposeViewControllerDelegate {
    enum EGSegueIdentifier: String {
        case person, dismiss
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
            navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        } else {
            navigationItem.title = NSLocalizedString("edit-booking", comment: "")
        }
    }

    @objc private func cancel() {
        performSegue(withIdentifier: .dismiss, sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            fatalError("Invalid segue identifier \(segue.identifier)")
        }
        guard let EGSegueIdentifier = EGSegueIdentifier(rawValue: identifier) else {
            fatalError("Invalid segue identifier \(identifier)")
        }
        switch EGSegueIdentifier {
        case .person:
            if let c = segue.destination as? PersonViewController {
                c.delegate = self
            }
        case .dismiss: break
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
        guard let type = BookingTableCellType(rawValue: activeRow) else {
            fatalError("ERROR: Unable to find type for row \(activeRow)")
        }
        return type.editCellType
    }

    override func cell(atAdjusted indexPath: IndexPath) -> UITableViewCell {
        guard let type = BookingTableCellType(rawValue: indexPath.row) else {
            fatalError("ERROR: Unable to find type for row \(indexPath.row)")
        }
        switch type {
        case .inDate, .outDate:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as! DateCell
            let type = bookingTableCellType(forAdjusted: indexPath)
            cell.titleLabel?.text = type.localizedName
            switch type {
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
        if let type = BookingTableCellType(rawValue: activeRow) {
            return type.values(withBooking: booking, in: editingContext)
        }
        return nil
    }

    override var selectedItemsForEditCell: [String]? {
        guard let activeRow = activePath?.row else  {
            preconditionFailure("ERROR: Active cell undefined")
        }
        if let type = BookingTableCellType(rawValue: activeRow) {
            switch type {
            case .jobType:
                if booking.jobTypeValues.count > 0 {
                    return booking.jobTypeValues
                }
            default:
                if let value = type.value(withBooking: booking) {
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
        if let type = BookingTableCellType(rawValue: activeRow) {
            type.processDidSelectValue(value, at: index, booking: booking)
        }

        tableView.reloadRows(at: [activePath!, editorPath!], with: .automatic)
    }

    override func editCellDidCollapse(at indexPath: IndexPath) {
        if let type = BookingTableCellType(rawValue: indexPath.row) {
            if let indexPaths = type.indexPathsForDependentMappings {
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

    // MARK: PersonEditViewControllerDelegate
    func personControllerDidChangeState(_ state: PersonViewController.State) {
        switch state {
        case .add, .edit:
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        case .view:
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }

    // MARK: Helpers
    private func description(forRow row: Int) -> String {
        if let BookingTableCellType = BookingTableCellType(rawValue: row) {
            if let value = BookingTableCellType.value(withBooking: booking) {
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
