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

class BookingsViewController: RecordsViewController, EGSegueHandlerType, UITableViewDataSource, UITableViewDelegate {

    enum EGSegueIdentifier: String {
        case add = "add"
        case edit = "edit"
    }

    var fetchedResultsController: NSFetchedResultsController<Booking>!
    var booking: Booking? {
        if let indexPath = tableView.indexPathForSelectedRow {
            return fetchedResultsController.object(at: indexPath)
        }
        return nil
    }
    
    override func initializeFetchedResultsController() {
        let request = NSFetchRequest<Booking>(entityName: "Booking")
        let sort = NSSortDescriptor(key: "created", ascending: false)
        request.sortDescriptors = [sort]
        let frc = NSFetchedResultsController<Booking>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        fetchedResultsController = frc

        do {
            try frc.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("bookings", comment: "")
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
            if let indexPath = tableView?.indexPathForSelectedRow {
                let n: UINavigationController = segue.destination as! UINavigationController
                let c: EditBookingViewController = n.topViewController as! EditBookingViewController
                c.booking = fetchedResultsController.object(at: indexPath)
            }
        }
    }

    // MARK: UITableViewDataSource & Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        configure(cell: cell, indexPath: indexPath);
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: .edit, sender: tableView.cellForRow(at: indexPath))
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: UITableViewDataSource & Delegate

    // MARK: Private
    private func configure(cell: UITableViewCell, indexPath: IndexPath) {
        let record = fetchedResultsController.object(at: indexPath)
        guard let task = record.task else {
            preconditionFailure("Record must have a task")
        }
        if let type = JobType(rawValue: Int(task.type)) {
            cell.textLabel?.text = type.localizedName
        }
        cell.detailTextLabel?.text = record.guid
    }
}

