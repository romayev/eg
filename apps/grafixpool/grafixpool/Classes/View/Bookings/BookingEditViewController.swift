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

class BookingEditViewController: EGEditTableViewController, EGSegueHandlerType, NSFetchedResultsControllerDelegate, MFMailComposeViewControllerDelegate {
    enum EGSegueIdentifier: String {
        case person, dismiss
    }
    enum ViewState {
        enum Presentation {
            case modal, show
        }

        case none, add, edit(Presentation)

        func update(_ c: BookingEditViewController) {
            switch self {
            case .add:
                c.toolbar.isHidden = true
                c.navigationItem.title = NSLocalizedString("add-booking", comment: "")
                c.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: c, action: #selector(cancel))
            case .edit(.show):
                c.navigationItem.title = NSLocalizedString("edit-booking", comment: "")
            case .edit(.modal):
                c.navigationItem.title = NSLocalizedString("edit-booking", comment: "")
                c.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: c, action: #selector(cancel))
            case .none:
                fatalError("Invalid state")
            }
            c.navigationItem.rightBarButtonItem?.isEnabled = c.booking.isValid
        }
        func dismiss(_ c: BookingEditViewController) {
            switch self {
            case .add, .edit(.modal):
                c.dismiss(animated: true, completion: nil)
            case .edit(.show):
                if let navigationController = c.navigationController {
                    navigationController.popViewController(animated: true)
                }
            case .none:
                fatalError("Invalid state")
            }
        }
        func save(_ c: BookingEditViewController) {
            switch self {
            case .add:
                c.send(email: .add)
            case .edit:
                let alertController = UIAlertController(title: nil, message: NSLocalizedString("booking.email-update-message", comment: ""), preferredStyle: .actionSheet)
                let yes = UIAlertAction(title: NSLocalizedString(NSLocalizedString("yes", comment: ""), comment: ""), style: .default, handler: { (action) in
                    c.send(email: .update)
                })
                let no = UIAlertAction(title: NSLocalizedString(NSLocalizedString("no", comment: ""), comment: ""), style: .default, handler: { (action) in
                    BookingNotification.update.processNotification(for: c.booking)
                    DataStore.store.save(editing: c.editingContext)
                    self.dismiss(c)
                })
                alertController.addAction(yes)
                alertController.addAction(no)
                c.present(alertController, animated: true, completion: nil)
            case .none:
                fatalError("Invalid state")
            }
        }
    }

    // MARK: Outlets
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var nextBarButtonItem: UIBarButtonItem!
    @IBOutlet var deleteBarButtonItem: UIBarButtonItem!

    // MARK: vars
    var booking: Booking!
    private let editingContext = DataStore.store.editingContext
    private var viewState: ViewState = .none
    private var personResultsController: NSFetchedResultsController<Person>!

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        nextBarButtonItem.title = NSLocalizedString("next", comment: "")
        deleteBarButtonItem.title = NSLocalizedString("cancel-booking", comment: "")
        initializePersonResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch viewState {
        case .none:
            if (booking == nil) {
                booking = Booking(context: editingContext)
                viewState = .add
            } else {
                booking = editingContext.object(with: booking.objectID) as! Booking
                if (isModal) {
                    viewState = .edit(.modal)
                } else {
                    viewState = .edit(.show)
                }
            }

            viewState.update(self)
        default:
            break
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
        case .person: break
        case .dismiss: break
        }
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(watchOS) || os(tvOS))
            DataStore.store.save(editing: editingContext)
            viewState.dismiss(self)
        #else
            viewState.save(self)
        #endif
    }

    @IBAction func deleteBooking(_ sender: UIBarButtonItem) {
        #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(watchOS) || os(tvOS))
            editingContext.delete(booking)
            DataStore.store.save(editing: editingContext)
            viewState.dismiss(self)
        #else
            send(email: .cancel)
        #endif
    }

    // MARK: EGEditTableViewController
    override var count: Int { return BookingTableCellType.count }

    override func isCellEditable(at indexPath: IndexPath) -> Bool {
        guard let type = BookingTableCellType(rawValue: indexPath.row) else {
            fatalError("ERROR: Unable to find type for row \(indexPath.row)")
        }
        return type != .person
    }

    override func processCustomSelect(at indexPath: IndexPath) {
        guard let type = BookingTableCellType(rawValue: indexPath.row) else {
            fatalError("ERROR: Unable to find type for row \(indexPath.row)")
        }
        switch type {
        case .person:
            performSegue(withIdentifier: .person, sender: tableView.cellForRow(at: indexPath))
        default:
            break
        }
    }

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
            if type == .person {
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.accessoryType = .none
            }
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

    // MARK: MFMailComposeViewControllerDelegate
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
                self.viewState.dismiss(self)
            })
            alertController.addAction(ok)
            present(alertController, animated: true, completion: nil)
        default: break
        }
    }

    fileprivate func send(email: BookingEmail) {
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
            let alert = unableToSendMailErrorAlert()
            present(alert, animated: true, completion: nil)
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

    // MARK: FetchedResultsController
    func initializePersonResultsController() {
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        let sort = NSSortDescriptor(key: "created", ascending: true)
        request.sortDescriptors = [sort]
        let frc = NSFetchedResultsController<Person>(fetchRequest: request, managedObjectContext: DataStore.store.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        personResultsController = frc

        do {
            try frc.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let indexPath = IndexPath(item: BookingTableCellType.person.rawValue, section: 0)
        if booking.person == nil {
            guard let person = Person.defaultPerson(editingContext) else {
                preconditionFailure("No person")
            }
            booking.setPerson(person: person)
            viewState.update(self)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
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
