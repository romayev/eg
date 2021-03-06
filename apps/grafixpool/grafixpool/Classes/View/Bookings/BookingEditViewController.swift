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
                c.navigationItem.title = "add-booking".localized
                c.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: c, action: #selector(cancel))
            case .edit(.show):
                c.navigationItem.title = "edit-booking".localized
            case .edit(.modal):
                c.navigationItem.title = "edit-booking".localized
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
                let alertController = UIAlertController(title: nil, message: "booking.email-update-message".localized, preferredStyle: .actionSheet)
                let yes = UIAlertAction(title: "yes".localized, style: .default, handler: { (action) in
                    c.send(email: .update)
                })
                let no = UIAlertAction(title: "no".localized, style: .default, handler: { (action) in
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
        nextBarButtonItem.title = "next".localized
        deleteBarButtonItem.title = "cancel-booking".localized
        initializePersonResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch viewState {
        case .none:
            if booking == nil {
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
            fatalError("Invalid segue identifier in \(segue)")
        }
        guard let segueIdentifier = EGSegueIdentifier(rawValue: identifier) else {
            fatalError("Invalid segue identifier \(identifier)")
        }
        switch segueIdentifier {
        case .person: break
        case .dismiss: break
        }
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        if (!editingContext.hasChanges) {
            viewState.dismiss(self)
            return
        }

        if !checkDates() {
            return
        }
        if isSimulator {
            DataStore.store.save(editing: editingContext)
            viewState.dismiss(self)
        } else {
            collapse()
            viewState.save(self)
        }
    }

    @IBAction func deleteBooking(_ sender: UIBarButtonItem) {
        if isSimulator {
            editingContext.delete(booking)
            DataStore.store.save(editing: editingContext)
            viewState.dismiss(self)
        } else {
            let alertController = UIAlertController(title: nil, message: "booking.email-update-message".localized, preferredStyle: .actionSheet)
            let yes = UIAlertAction(title: "yes".localized, style: .default, handler: { (action) in
                self.send(email: .cancel)
            })
            let no = UIAlertAction(title: "no".localized, style: .default, handler: { (action) in
                BookingNotification.cancel.processNotification(for: self.booking)
                self.editingContext.delete(self.booking)
                DataStore.store.save(editing: self.editingContext)
                self.viewState.dismiss(self)
            })
            alertController.addAction(yes)
            alertController.addAction(no)
            present(alertController, animated: true, completion: nil)
        }
    }

    private func checkDates() -> Bool {
        let inDate = booking.inDate! as Date
        let outDate = booking.outDate! as Date

        if inDate > outDate {
            let alertController = UIAlertController(
                title: "booking.edit.invalid-dates-title".localized,
                message: "booking.edit.invalid-dates-desc".localized, preferredStyle: .alert)
            let ok = UIAlertAction(title: "ok".localized, style: .default, handler: nil)
            alertController.addAction(ok)
            present(alertController, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }

    // MARK: EGEditTableViewController
    override var count: Int { return BookingAttribute.editCount }

    override func isCellEditable(at indexPath: IndexPath) -> Bool {
        guard let type = BookingAttribute(rawValue: indexPath.row) else {
            fatalError("ERROR: Unable to find type for row \(indexPath.row)")
        }
        return type != .person
    }

    override func processCustomSelect(at indexPath: IndexPath) {
        guard let type = BookingAttribute(rawValue: indexPath.row) else {
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
        guard let attribute = BookingAttribute(rawValue: activeRow) else {
            fatalError("ERROR: Unable to find attribute for row \(activeRow)")
        }
        return attribute.editCellType
    }

    override func cell(atAdjusted indexPath: IndexPath) -> UITableViewCell {
        guard let attribute = BookingAttribute(rawValue: indexPath.row) else {
            fatalError("ERROR: Unable to find attribute for row \(indexPath.row)")
        }
        switch attribute {
        case .inDate, .outDate:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as! DateCell
            let type = bookingAttribute(forAdjusted: indexPath)
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
            let attribute = bookingAttribute(forAdjusted: indexPath)
            cell.textLabel?.text = attribute.localizedName
            cell.detailTextLabel?.text = self.description(forRow: indexPath.row)
            if attribute == .person {
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
        if let attribute = BookingAttribute(rawValue: activeRow) {
            return attribute.values(with: booking, in: editingContext)
        }
        return nil
    }

    override var selectedItemsForEditCell: [String]? {
        guard let activeRow = activePath?.row else  {
            preconditionFailure("ERROR: Active cell undefined")
        }
        if let attribute = BookingAttribute(rawValue: activeRow) {
            switch attribute {
            case .jobType:
                if booking.jobTypeValues.count > 0 {
                    return booking.jobTypeValues
                }
            default:
                if let value = attribute.value(with: booking) {
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
        if let attribute = BookingAttribute(rawValue: activeRow) {
            if attribute == .project {
                
            }
            attribute.processDidSelectValue(value, at: index, booking: booking)
        }

        tableView.reloadRows(at: [activePath!, editorPath!], with: .automatic)
    }

    override func editCellDidCollapse(at indexPath: IndexPath) {
        if let attribute = BookingAttribute(rawValue: indexPath.row) {
            if let indexPaths = attribute.indexPathsForDependentMappings {
                let adjusted = indexPaths.map { adjustedPath(forIndexPath: $0) }
                tableView.reloadRows(at: adjusted, with: .automatic)
            }
        }
    }

    // MARK: EGAddPickerEditCellDelegate
    override func editCellDidAdd(value: String) {
        if Project.project(with: value, in: editingContext) != nil {
            let alertController = UIAlertController(title: "booking.edit.duplicate-project-title".localized, message: "booking.edit.duplicate-project-desc".localized, preferredStyle: .alert)
            let ok = UIAlertAction(title: "ok".localized, style: .default, handler: nil)
            alertController.addAction(ok)
            present(alertController, animated: true, completion: nil)
            return;
        }

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
            let attribute = bookingAttribute(forAdjusted: activePath)
            assert(attribute == .inDate || attribute == .outDate, "Unexpected attribute for row: \(activePath.row)")

            var result = Date().addingTimeInterval(3600 * 8)
            switch attribute {
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
            let attribute = bookingAttribute(forAdjusted: activePath)
            assert(attribute == .inDate || attribute == .outDate, "Unexpected attribute for row: \(activePath.row)")
            switch attribute {
            case .inDate:
                booking.inDate = NSDate(timeIntervalSinceReferenceDate: newValue.timeIntervalSinceReferenceDate)
                if (booking.outDate! as Date) < (booking.inDate! as Date) {
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
        if let attribute = BookingAttribute(rawValue: row) {
            if let value = attribute.value(with: booking) {
                return value
            }
        }
    return "--"
    }

    private func bookingAttribute(forAdjusted indexPath: IndexPath) -> BookingAttribute {
        guard let attribute = BookingAttribute(rawValue: indexPath.row) else {
            fatalError("Unable to get BookingAttribute for row \(indexPath.row)")
        }
        return attribute
    }

    // MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        let title = "email.alert.title".localized
        var message = "email.alert.message.success".localized
        if error != nil {
            let m = "email.alert.message.error".localized
            let e = String(describing: error)
            message = "\(m) \(e)"
        }

        switch result {
        case .sent:
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "ok".localized, style: .default, handler: { (action) in
                DataStore.store.save(editing: self.editingContext)
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
            })
        } else {
            let alert = unableToSendMailErrorAlert()
            present(alert, animated: true, completion: nil)
        }
    }

    private func configuredMailComposeViewController(email: BookingEmail) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.navigationBar.tintColor = UIColor.white

        let message = email.bookingMessage(with: booking)
        mailComposerVC.setToRecipients(message.recipients(with: booking))
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
        let indexPath = IndexPath(item: BookingAttribute.person.rawValue, section: 0)
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
