//
//  MoreViewController.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/16/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import UIKit
import EGKit

class MoreViewController: EGViewController {
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var titleAboutLabel: UILabel!
    @IBOutlet var titleContactLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var contactNameLabel: UILabel!
    @IBOutlet var contactTitleLabel: UILabel!
    @IBOutlet var contactTextView: UITextView!
    @IBOutlet var contactTextViewHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        if (UIScreen.main.bounds.size.height <= 568.0) {
            backgroundImageView.isHidden = true
        }
        navigationItem.title = NSLocalizedString("ingredion", comment: "ingredion")
        titleAboutLabel.text = NSLocalizedString("more.title-about", comment: "more.title-about")
        titleContactLabel.text = NSLocalizedString("more.title-contact", comment: "more.title-contact")
        descLabel.text = NSLocalizedString("more.desc", comment: "more.desc")
        contactNameLabel.text = NSLocalizedString("more.contact.name", comment: "more.contact.name")
        contactTitleLabel.text = NSLocalizedString("more.contact.title", comment: "more.contact.title")
        contactTextView.text = NSLocalizedString("more.contact.email-phone", comment: "more.contact.email-phone")
        let size = contactTextView.sizeThatFits(CGSize(width: contactTextView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        contactTextViewHeightConstraint.constant = size.height
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        if newCollection.horizontalSizeClass == .compact && newCollection.verticalSizeClass == .compact {
            backgroundImageView.alpha = 0.0
        } else {
            backgroundImageView.alpha = 1.0
        }
    }
}
