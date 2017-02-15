//
//  HomeSplitViewController.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/13/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import UIKit

class HomeSplitViewController : UISplitViewController, UISplitViewControllerDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.traitCollection.userInterfaceIdiom == .phone {
            self.preferredDisplayMode = .allVisible
        }
    }

    // MARK: UISplitViewControllerDelegate
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if self.traitCollection.userInterfaceIdiom == .phone {
            return true
        }
        return false
    }
}
