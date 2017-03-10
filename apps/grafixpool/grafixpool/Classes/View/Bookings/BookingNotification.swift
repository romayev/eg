//
//  BookingNotification.swift
//  grafixpool
//
//  Created by Alex Romayev on 3/9/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import UserNotifications

enum BookingNotification: String {
    case add, update, cancel

    func processNotification(for booking: Booking) {
        guard let bookingID = booking.bookingID else {
            preconditionFailure("Booking ID is not set")
        }
        switch self {
        case .cancel: break
        case .add, .update:
            if booking.reminder > 0 {
                let center = UNUserNotificationCenter.current()
                let options: UNAuthorizationOptions = [.alert, .sound]
                center.requestAuthorization(options: options) { (granted, error) in
                    if granted && error == nil {
                        center.getNotificationSettings { (settings) in
                            if settings.authorizationStatus == .authorized {
                                switch self {
                                case .add, .update:
                                    self.addNotification(for: booking, with: center)
                                case .cancel:
                                    center.removePendingNotificationRequests(withIdentifiers: [bookingID])
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func addNotification(for booking: Booking, with center: UNUserNotificationCenter) {
        guard let inDate = booking.inDate?.format else {
            preconditionFailure("IN date is not set")
        }
        guard let outDate = booking.outDate?.format else {
            preconditionFailure("OUT date is not set")
        }
        guard let bookingID = booking.bookingID else {
            preconditionFailure("bookingID is not set")
        }

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("reminder", comment: "")

        let subtitlePrefix = NSLocalizedString("booking", comment: "")
        content.subtitle = "\(subtitlePrefix): \(bookingID)"

        let inTitle = NSLocalizedString("booking.in", comment: "")
        let outTitle = NSLocalizedString("booking.out", comment: "")
        content.body = "\(inTitle) \(inDate), \(outTitle) \(outDate)"

        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 20, repeats: false)
        content.categoryIdentifier = "booking-actions"

        let identifier = booking.bookingID
        let request = UNNotificationRequest(identifier:  identifier!, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                print("Error scheduling notification \(error)")
            }
        })
    }
}
