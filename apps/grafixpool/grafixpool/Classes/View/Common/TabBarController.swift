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
            print("Default")
        case BookingNotification.update.rawValue:
            performSegue(withIdentifier: .notificationBookingEdit, sender: nil)
        case BookingNotification.cancel.rawValue:
            send(email: .cancel)
        default:
            break
        }

        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }

    // MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        let title = NSLocalizedString("email.alert.title", comment: "")
        var message = NSLocalizedString("email.alert.message.success", comment: "")
        if error != nil {
            let m = NSLocalizedString("email.alert.message.error", comment: "")
            message = "\(m) \(error)"
        }

        switch result {
        case .sent:
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: NSLocalizedString(NSLocalizedString("ok", comment: ""), comment: ""), style: .default, handler: nil)
            alertController.addAction(ok)
            present(alertController, animated: true, completion: nil)
        default: break
        }
    }

    fileprivate func send(email: BookingEmail) {
        guard let notificationBooking = notificationBooking else {
            fatalError("No booking")
        }
        let mailComposeViewController = configuredMailComposeViewController(email: email, booking: notificationBooking)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: {
                BookingNotification.cancel.processNotification(for: notificationBooking)
                let editingContext = DataStore.store.editingContext
                let booking = editingContext.object(with: notificationBooking.objectID)
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

        let message = email.bookingMessage(with: booking)
        mailComposerVC.setToRecipients(message.recipients)
        mailComposerVC.setSubject(message.subject)
        mailComposerVC.setMessageBody(message.body, isHTML: false)

        return mailComposerVC
    }

}
