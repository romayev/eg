//
//  BookingsViewController.swift
//  grafixpool
//
//  Created by Alex Romayev on 2/24/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import UIKit
import CoreData
import EGKit
import UserNotifications

class BookingsViewController: RecordsViewController, EGSegueHandlerType, UITableViewDataSource, UITableViewDelegate {
    enum EGSegueIdentifier: String {
        case add = "add"
        case edit = "edit"
    }

    private enum ViewState {
        case recent, all
        var fromDate: NSDate? {
            switch self {
            case .recent:
                return NSDate().removingTime
            default:
                return nil
            }
        }
    }
    private enum FetchState {
        case records, noRecords
    }

    @IBOutlet var noRecordsView: UIView!
    @IBOutlet var noRecordsLabel: UILabel!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var slidesHeaderLabel: UILabel!
    @IBOutlet var inHeaderLabel: UILabel!
    @IBOutlet var outHeaderLabel: UILabel!
    private var viewState: ViewState = .recent
    private var fetchState: FetchState = .noRecords

    var fetchedResultsController: NSFetchedResultsController<Booking>!
    var booking: Booking? {
        get {
            if let indexPath = tableView.indexPathForSelectedRow {
                return fetchedResultsController.object(at: indexPath)
            }
            return nil
        }
    }
    var alertBooking: Booking?

    override func initializeFetchedResultsController() {
        let request: NSFetchRequest<Booking> = Booking.fetchRequest()
        if let fromDate = viewState.fromDate {
            request.predicate = NSPredicate.init(format: "inDate >= %@", fromDate)
        }
        let sort = NSSortDescriptor(key: "inDate", ascending: false)
        request.sortDescriptors = [sort]
        let frc = NSFetchedResultsController<Booking>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "sectionIdentifier", cacheName: nil)
        frc.delegate = self
        fetchedResultsController = frc

        do {
            try frc.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        updateFetchState()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("bookings", comment: "")
        navigationItem.title = NSLocalizedString("bookings", comment: "")
        segmentedControl.setTitle(NSLocalizedString("recent", comment: ""), forSegmentAt: 0)
        segmentedControl.setTitle(NSLocalizedString("all", comment: ""), forSegmentAt: 1)
        noRecordsLabel.text = NSLocalizedString("no-bookings", comment: "")
        slidesHeaderLabel.text = NSLocalizedString("booking.slides", comment: "")
        inHeaderLabel.text = NSLocalizedString("booking.in", comment: "")
        outHeaderLabel.text = NSLocalizedString("booking.out", comment: "")

        if alertBooking != nil {
            performSegue(withIdentifier: .edit, sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            fatalError("Invalid segue identifier \(segue.identifier)")
        }
        guard let EGSegueIdentifier = EGSegueIdentifier(rawValue: identifier) else {
            fatalError("Invalid segue identifier \(identifier)")
        }
        switch EGSegueIdentifier {
        case .add: break
        case .edit:
            if let alertBooking = alertBooking {
                let n: UINavigationController = segue.destination as! UINavigationController
                let c: EditBookingViewController = n.topViewController as! EditBookingViewController
                c.booking = alertBooking
                self.alertBooking = nil
            } else if let indexPath = tableView?.indexPathForSelectedRow {
                let n: UINavigationController = segue.destination as! UINavigationController
                let c: EditBookingViewController = n.topViewController as! EditBookingViewController
                c.booking = fetchedResultsController.object(at: indexPath)
            }
        }
    }

    // MARK: Actions
    @IBAction func toggleViewState(_ sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0) {
            viewState = .recent
        } else {
            viewState = .all
        }
        fetchedResultsController = nil;
        initializeFetchedResultsController()
        tableView.reloadData()
    }

    // MARK: UITableViewDataSource & Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            print("No sections in fetchedResultsController")
            return 0
        }
        let currentSection = sections[section]
        return currentSection.numberOfObjects
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "Header")
        return header
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let titleLabel = view.viewWithTag(100) as! UILabel
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            let df1 = DateFormatter()
            df1.dateFormat = "yyyy-MM-dd"
            let df2 = DateFormatter()
            df2.dateStyle = .medium
            df2.doesRelativeDateFormatting = true

            let date = df2.string(from: df1.date(from: currentSection.name)!)
            titleLabel.text = date
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BookingCell
        configure(cell: cell, indexPath: indexPath);
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: .edit, sender: tableView.cellForRow(at: indexPath))
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: Private
    override func updateFetchState() {
        if let count = fetchedResultsController.fetchedObjects?.count {
            fetchState = count > 0 ? .records : .noRecords
        } else {
            fetchState = .noRecords
        }
        switch fetchState {
        case .records:
            noRecordsView.isHidden = true
        case .noRecords:
            noRecordsView.isHidden = false
        }
    }
    
    private func configure(cell: BookingCell, indexPath: IndexPath) {
        let booking = fetchedResultsController.object(at: indexPath)
        cell.slidesLabel.text = String(booking.slideCount)
        if (isCurrentTimeZoneCET()) {
            for label in cell.singleTimeZoneLabels {
                label.isHidden = false
            }
            for label in cell.mutliTimeZoneLabels {
                label.isHidden = true
            }
            cell.outLabel.text = booking.outDate?.format
            cell.inLabel.text = booking.inDate?.format
        } else {
            for label in cell.singleTimeZoneLabels {
                label.isHidden = true
            }
            for label in cell.mutliTimeZoneLabels {
                label.isHidden = false
            }
            cell.inTopLabel.text = booking.inDate?.format
            cell.inBottomLabel.text = booking.inDate?.inCETTimeZone.formatCET
            cell.outTopLabel.text = booking.outDate?.format
            cell.outBottomLabel.text = booking.outDate?.inCETTimeZone.formatCET
        }
    }
}

extension BookingsViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let bookingID = response.notification.request.identifier
        if let booking = Booking.with(bookingID, context: DataStore.store.viewContext) {
            switch response.actionIdentifier {
            case UNNotificationDismissActionIdentifier:
                break
            case UNNotificationDefaultActionIdentifier:
                print("Default")
            case BookingNotification.update.rawValue:
                self.alertBooking = booking
                performSegue(withIdentifier: .edit, sender: nil)
            case BookingNotification.cancel.rawValue:
                print("Delete")
            default:
                break
            }
        }

        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }

}
class BookingCell: UITableViewCell {
    @IBOutlet var slidesLabel: UILabel!
    @IBOutlet var inLabel: UILabel!
    @IBOutlet var outLabel: UILabel!
    @IBOutlet var inTopLabel: UILabel!
    @IBOutlet var inBottomLabel: UILabel!
    @IBOutlet var outTopLabel: UILabel!
    @IBOutlet var outBottomLabel: UILabel!

    @IBOutlet var singleTimeZoneLabels: [UILabel]!
    @IBOutlet var mutliTimeZoneLabels: [UILabel]!
}
