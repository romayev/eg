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
        let title = "[\(prefix)] \(emailSubject(with: booking))"
        return BookingMessage(subject: title, body: emailBody(with: booking))
    }

    func emailSubject(with booking: Booking) -> String {
        let slides = booking.slides

        guard let project = booking.project?.code else {
            preconditionFailure()
        }
        guard let person = booking.person?.formatted else {
            preconditionFailure()
        }
        guard let inDate = booking.inDate?.inCETTimeZone.formatCET else {
            preconditionFailure()
        }
        guard let outDate = booking.outDate?.inCETTimeZone.formatCET else {
            preconditionFailure()
        }
        guard let confidentiality = Confidentiality(rawValue: Int(booking.confidentiality))?.localizedName else {
            preconditionFailure()
        }
        let inTitle = NSLocalizedString("booking.in", comment: "")
        let outTitle = NSLocalizedString("booking.out", comment: "")

        return "\(slides) / \(project) / \(person) / \(inTitle): \(inDate) / \(outTitle): \(outDate) / \(confidentiality)"
    }

    func emailBody(with booking: Booking) -> String {
        let statusTitle = NSLocalizedString("status", comment: "")

        let values = booking.jobTypeValues
        let jobTypeValues = values.count > 0 ? booking.jobTypeValues.joined(separator: ", ") : nil

        let body = formatBody(values: [
            NSLocalizedString("booking.edit.booking-id", comment: ""): booking.bookingID,
            NSLocalizedString("booking.edit.person", comment: ""): booking.person?.formatted,
            NSLocalizedString("booking.edit.project", comment: ""): booking.project?.code,
            NSLocalizedString("booking.edit.in", comment: ""): booking.inDate?.inCETTimeZone.formatCET,
            NSLocalizedString("booking.edit.out", comment: ""): booking.outDate?.inCETTimeZone.formatCET,
            NSLocalizedString("booking.edit.confidentiality", comment: ""): Confidentiality(rawValue: Int(booking.confidentiality))?.localizedName,
            NSLocalizedString("booking.edit.job-type", comment: ""): jobTypeValues,
            NSLocalizedString("booking.edit.notes", comment: ""): booking.notes,
            NSLocalizedString("booking.edit.slides", comment: ""): booking.slides
            ]
        )
        switch self {
        case .add:
            let status = format(title: statusTitle, value: NSLocalizedString("booking.email.status-new", comment: ""))
            return "\(status)\(body)"
        case .update:
            let status = format(title: statusTitle, value: NSLocalizedString("booking.email.status-update", comment: ""))
            return "\(status)\(body)"
        case .cancel:
            let status = format(title: statusTitle, value: NSLocalizedString("booking.email.status-cancel", comment: ""))
            return "\(status)\(body)"
        }
    }
    private func format(title: String , value: String) -> String {
        return "\(title): \(value)\n"
    }
    private func formatBody(values: [String: String?]) -> String {
        var body = ""
        let keys = values.keys.sorted()
        for key in keys {
            if let value = values[key] ?? nil {
                body = "\(body)\(format(title: key, value: value))"
            }
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
