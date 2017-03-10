//
//  BookingEmail.swift
//  grafixpool
//
//  Created by Alex Romayev on 3/9/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
enum BookingEmail {
    case add, update, cancel

    func bookingMessage(with booking: Booking) -> BookingMessage {
        guard let bookingID = booking.bookingID else {
            preconditionFailure("No booking ID")
        }
        var prefix: String
        switch self {
        case .add:
            prefix = NSLocalizedString("booking.email.subject-new", comment: "")
        case .update:
            prefix = NSLocalizedString("booking.email.subject-update", comment: "")
        case .cancel:
            prefix = NSLocalizedString("booking.email.subject-cancel", comment: "")
        }
        let title = "\(prefix): \(bookingID)"
        return BookingMessage(subject: title, body: emailBody(with: booking))
    }

    func emailBody(with booking: Booking) -> String {
        let statusTitle = NSLocalizedString("status", comment: "")

        let values = booking.jobTypeValues
        let jobTypeValues = values.count > 0 ? booking.jobTypeValues.joined(separator: ", ") : nil

        let body = formatBody(values: [
            NSLocalizedString("booking.edit.booking-id", comment: ""): booking.bookingID,
            NSLocalizedString("booking.edit.project", comment: ""): booking.project?.code,
            NSLocalizedString("booking.edit.in", comment: ""): booking.inDate?.inCETTimeZone.format,
            NSLocalizedString("booking.edit.out", comment: ""): booking.outDate?.inCETTimeZone.format,
            NSLocalizedString("booking.edit.confidentiality", comment: ""): Confidentiality(rawValue: Int(booking.confidentiality))?.localizedName,
            NSLocalizedString("booking.edit.job-type", comment: ""): jobTypeValues,
            NSLocalizedString("booking.edit.notes", comment: ""): booking.notes
            ]
        )
        switch self {
        case .add:
            let status = format(title: statusTitle, value: NSLocalizedString("booking.email.status-add", comment: ""))
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

