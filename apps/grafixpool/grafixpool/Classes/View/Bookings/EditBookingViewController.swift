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

class EditBookingViewController: EGEditTableViewController {

    let editingContext = DataStore.store.editingOjbectContext
    var booking: Booking?

    override var count: Int { return BookingTableCellType.count }

    // MARK: EGEditDropDownCellDelegate - vars
    override var dropDownItems: [String]? {
        guard let activeRow = activeCellPath?.row else  {
            print("ERROR: Active cell undefined")
            return nil
        }
        switch activeRow {
        case 0:
            return JobType.localizedValues
        case 3:
            return Layout.localizedValues
        case 5:
            return AspectRatio.localizedValues
        case 6:
            return Confidentiality.localizedValues
        default:
            return nil
        }
    }
    override var selectedItems: [String]? {
//        guard let activeCellPath = self.activeCellPath else {
//            return nil
//        }
        return nil
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
        guard let type = BookingTableCellType(rawValue: indexPath.row) else {
            fatalError("Unable to get BookingTableCellType for index \(indexPath.row)")
        }
        cell.textLabel?.text = type.localizedName
        cell.detailTextLabel?.text = self.descriptionForRow(row)
        return cell
    }

    // MARK: EGEditDropDownCellDelegate - funcs
    override func cell(_ cell: UITableViewCell, didSelectValue value: String, atIndex index: Int) {
    }

    // MARK: Helpers
    private func descriptionForRow(_ row: Int) -> String {
        return "description"
    }
}
