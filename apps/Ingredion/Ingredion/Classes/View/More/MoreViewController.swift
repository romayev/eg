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
        navigationItem.title = "ingredion".localized
        titleAboutLabel.text = "more.title-about".localized
        titleContactLabel.text = "more.title-contact".localized
        descLabel.text = "more.desc".localized
        contactNameLabel.text = "more.contact.name".localized
        contactTitleLabel.text = "more.contact.title".localized
        contactTextView.text = "more.contact.email-phone".localized
        let size = contactTextView.sizeThatFits(CGSize(width: contactTextView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        contactTextViewHeightConstraint.constant = size.height
    }

    override func viewWillLayoutSubviews() {
        let size = view.bounds.size
        let showBackgroundImage = size.height > 568.0
        if showBackgroundImage {
            backgroundImageView.alpha = 1.0
        } else {
            backgroundImageView.alpha = 0.0
        }
        backgroundImageView.isHidden = !showBackgroundImage
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.backgroundImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.25, animations: { 
                self.backgroundImageView.transform = CGAffineTransform.identity
            })
        }
    }
//    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
//        if newCollection.horizontalSizeClass == .compact && newCollection.verticalSizeClass == .compact {
//            backgroundImageView.alpha = 0.0
//        } else {
//            backgroundImageView.alpha = 1.0
//        }
//    }
}
