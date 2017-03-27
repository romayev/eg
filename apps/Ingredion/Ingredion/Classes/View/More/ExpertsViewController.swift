//
//  ExpertsViewController.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/18/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import UIKit
import EGKit

protocol ExpertsViewControllerDelegate: class {
    var productType: ProductType! { get }
}

class ExpertsViewController: EGViewController {
    @IBOutlet var noInfoLabel: UILabel!
    @IBOutlet var containerView: UIView!
    weak var delegate: ExpertsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "exerts".localized
        if let productType: ProductType = delegate?.productType {
            if (productType == .beverages) {
                noInfoLabel.isHidden = false
                containerView.isHidden = true
            } else {
                noInfoLabel.isHidden = true
                containerView.isHidden = false
            }
        }
    }
}
