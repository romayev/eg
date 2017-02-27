//
//  BookingsViewController.swift
//  grafixpool
//
//  Created by Alex Romayev on 2/24/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import UIKit
import CoreData

class BookingsViewController: RecordsViewController, UITableViewDataSource, UITableViewDelegate {
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
        let identifier = segue.identifier
        if identifier == "edit" {
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
        
    }

    // MARK: UITableViewDataSource & Delegate

    // MARK: Private
    private func configure(cell: UITableViewCell, indexPath: IndexPath) {
        let record = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = record.guid
    }
}

