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

class EditBookingViewController: EditTableViewController {

    let editingContext = DataStore.store.editingOjbectContext
    var booking: Booking?

    override var count: Int { return 5 }

    // MARK: DropDownCellDelegate - vars
    override var dropDownItems: [String]? {
//        guard let activeRow = activeCellPath?.row else  {
//            print("ERROR: Active cell undefined")
//            return nil
//        }
        return [ "One", "Two", "Three" ]
    }
    override var selectedItems: [String]? {
//        guard let activeCellPath = self.activeCellPath else {
//            return nil
//        }
        return [ "Two" ]
    }

    // MARK: UIViewController
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if booking != nil {
            if let objectID = booking?.objectID {
                booking = editingContext.object(with: objectID) as? Booking
            }
            navigationItem.title = NSLocalizedString("edit-booking", comment: "")
        } else {
            booking = Booking.create(context: editingContext)
            navigationItem.title = NSLocalizedString("add-booking", comment: "")
        }
    }

    override func cellFor(_ row: Int, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Test"
        cell.detailTextLabel?.text = self.descriptionForRow(row)
        return cell
    }

    // MARK: DropDownCellDelegate - funcs
    override func cell(_ cell: UITableViewCell, didSelectValue value: String, atIndex index: Int) {
    }

    // MARK: Helpers
    private func descriptionForRow(_ row: Int) -> String {
        return "description"
    }
}
