//
//  TabBarController.swift
//  grafixpool
//
//  Created by Alex Romayev on 3/13/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import UIKit
import UserNotifications
import EGKit
import MessageUI

class TabBarController: UITabBarController, EGSegueHandlerType, UNUserNotificationCenterDelegate, MFMailComposeViewControllerDelegate {
    enum EGSegueIdentifier: String {
        case notificationBookingEdit
    }
    var notificationBooking: Booking?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            fatalError("Invalid segue identifier \(segue.identifier)")
        }
        guard let EGSegueIdentifier = EGSegueIdentifier(rawValue: identifier) else {
            fatalError("Invalid segue identifier \(identifier)")
        }
        switch EGSegueIdentifier {
        case .notificationBookingEdit:
            if let n: UINavigationController = segue.destination as? UINavigationController {
                if let c: BookingEditViewController = n.topViewController as? BookingEditViewController {
                    c.booking = notificationBooking
                    notificationBooking = nil
                }
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let bookingID = response.notification.request.identifier
        notificationBooking = Booking.with(bookingID, context: DataStore.store.viewContext)
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            break
        case UNNotificationDefaultActionIdentifier:
            performSegue(withIdentifier: .notificationBookingEdit, sender: nil)
        case BookingNotification.update.rawValue:
            performSegue(withIdentifier: .notificationBookingEdit, sender: nil)
        case BookingNotification.cancel.rawValue:
            cancel(booking: notificationBooking!)
        default:
            break
        }

        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }

    func cancel(booking: Booking) {
        let alertController = UIAlertController(title: nil, message: "booking.email-update-message".localized, preferredStyle: .actionSheet)
        let yes = UIAlertAction(title: "yes".localized, style: .default, handler: { (action) in
            self.send(email: .cancel, booking: booking)
        })
        let no = UIAlertAction(title: "no".localized, style: .default, handler: { (action) in
            let editingContext = DataStore.store.editingContext
            editingContext.delete(editingContext.object(with: booking.objectID))
            DataStore.store.save(editing: editingContext)
        })
        alertController.addAction(yes)
        alertController.addAction(no)
        present(alertController, animated: true, completion: nil)

    }

    // MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        let title = "email.alert.title".localized
        var message = "email.alert.message.success".localized
        if error != nil {
            let m = "email.alert.message.error".localized
            message = "\(m) \(error)"
        }

        switch result {
        case .sent:
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "ok".localized, style: .default, handler: nil)
            alertController.addAction(ok)
            present(alertController, animated: true, completion: nil)
        default: break
        }
    }

    fileprivate func send(email: BookingEmail, booking: Booking) {
        let mailComposeViewController = configuredMailComposeViewController(email: email, booking: booking)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: {
                BookingNotification.cancel.processNotification(for: booking)
                let editingContext = DataStore.store.editingContext
                let booking: Booking = editingContext.object(with: booking.objectID) as! Booking
                BookingNotification.cancel.processNotification(for: booking)
                editingContext.delete(booking)
                DataStore.store.save(editing: editingContext)
            })
        } else {
            let alert = unableToSendMailErrorAlert()
            present(alert, animated: true, completion: nil)
        }
    }

    private func configuredMailComposeViewController(email: BookingEmail, booking: Booking) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.navigationBar.tintColor = UIColor.white

        let message = email.bookingMessage(with: booking)
        mailComposerVC.setToRecipients(message.recipients)
        mailComposerVC.setSubject(message.subject)
        mailComposerVC.setMessageBody(message.body, isHTML: false)

        return mailComposerVC
    }
}
