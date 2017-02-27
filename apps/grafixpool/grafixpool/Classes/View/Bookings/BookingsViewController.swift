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

class BookingsViewController: RecordsViewController, SegueHandlerType, UITableViewDataSource, UITableViewDelegate {

    enum SegueIdentifier: String {
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
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest<Booking>(entityName: "Booking")
        let sort = NSSortDescriptor(key: "created", ascending: false)
        request.sortDescriptors = [sort]
        let frc = NSFetchedResultsController<Booking>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self

        do {
            try frc.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("bookings", comment: "")
        initializeFetchedResultsController()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            fatalError("Invalid segue identifier \(segue.identifier)")
        }
        guard let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
            fatalError("Invalid segue identifier \(identifier)")
        }
        switch segueIdentifier {
        case .add: break
        case .edit:
            if let indexPath = tableView?.indexPathForSelectedRow {
                let c: EditBookingViewController = segue.destination as! EditBookingViewController
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
            fatalError("No sections in fetchedResultsController")
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
    }

    // MARK: UITableViewDataSource & Delegate

    // MARK: Private
    private func configure(cell: UITableViewCell, indexPath: IndexPath) {
        let record = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = record.guid
    }
}

