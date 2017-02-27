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

class EditBookingViewController: ViewController {
    let editingContext = DataStore.store.editingOjbectContext
    var booking: Booking?

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
}
