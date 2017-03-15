//
//  BookingEmail.swift
//  grafixpool
//
//  Created by Alex Romayev on 3/9/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import UIKit

struct BookingMessage {
    let recipients = [NSLocalizedString("booking.email.recipient", comment: "")]
    var subject: String
    var body: String

    init(subject: String, body: String) {
        self.subject = subject
        self.body = body
    }
}

enum BookingEmail {
    case add, update, cancel

    func bookingMessage(with booking: Booking) -> BookingMessage {
        var prefix: String
        switch self {
        case .add:
            prefix = NSLocalizedString("booking.email.status-new", comment: "")
        case .update:
            prefix = NSLocalizedString("booking.email.status-update", comment: "")
        case .cancel:
            prefix = NSLocalizedString("booking.email.status-cancel", comment: "")
        }
        let title = "[\(prefix) \(NSLocalizedString("booking", comment: ""))] \(emailSubject(with: booking))"
        return BookingMessage(subject: title, body: emailBody(with: booking))
    }

    func emailSubject(with booking: Booking) -> String {
        guard let project = booking.project?.code else {
            preconditionFailure()
        }
        guard let person = booking.person?.formatted else {
            preconditionFailure()
        }
        guard let confidentiality = Confidentiality(rawValue: Int(booking.confidentiality))?.localizedName else {
            preconditionFailure()
        }

        var array = [booking.slides, project, person, confidentiality]
        array.insert(contentsOf: [BookingAttribute.inDate, BookingAttribute.outDate].map { $0.formattedForEmail(with: booking)! }, at: 3)
        return array.joined(separator: " / ")
    }

    func emailBody(with booking: Booking) -> String {
        var body = ""

        let statusTitle = NSLocalizedString("status", comment: "")
        switch self {
        case .add:
            body = "\(statusTitle): \(NSLocalizedString("booking.email.status-new", comment: ""))"
        case .update:
            body = "\(statusTitle): \(NSLocalizedString("booking.email.status-update", comment: ""))"
        case .cancel:
            body = "\(statusTitle): \(NSLocalizedString("booking.email.status-cancel", comment: ""))"
        }
        body += "\n"

        if let bookingID = BookingAttribute.bookingID.formattedForEmail(with: booking) {
            body += bookingID
            body += "\n\n"
        }
        if let slides = BookingAttribute.slides.formattedForEmail(with: booking) {
            body += slides
            body += "\n"
        }
        if let project = BookingAttribute.project.formattedForEmail(with: booking) {
            body += project
            body += "\n"
        }
        if let person = BookingAttribute.person.formattedForEmail(with: booking) {
            body += person
            body += "\n"
        }
        if let inDate = BookingAttribute.inDate.formattedForEmail(with: booking) {
            body += inDate
            body += "\n"
        }
        if let outDate = BookingAttribute.outDate.formattedForEmail(with: booking) {
            body += outDate
            body += "\n"
        }
        if let confidentiality = BookingAttribute.confidentiality.formattedForEmail(with: booking) {
            body += confidentiality
            body += "\n\n"
        }
        if let jobType = BookingAttribute.jobType.formattedForEmail(with: booking) {
            body += jobType
            body += "\n\n"
        }
        if let comments = BookingAttribute.comments.formattedForEmail(with: booking) {
            body += comments
            body += "\n\n"
        }

        return body
    }
}

func unableToSendMailErrorAlert() -> UIAlertController {
    let title = NSLocalizedString("error", comment: "")
    let message = NSLocalizedString("email.alert.unable-to-send-mail", comment: "")
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let ok = UIAlertAction(title: NSLocalizedString(NSLocalizedString("ok", comment: ""), comment: ""), style: .default, handler: nil)
    alertController.addAction(ok)
    return alertController
}
