//
//  EGViewController.swift
//  EGKit
//
//  Created by Alex Romayev on 2/13/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import UIKit

open class EGViewController : UIViewController {
    public var isModal: Bool {
        return self.presentingViewController?.presentedViewController == self
            || (self.navigationController != nil && self.navigationController?.presentingViewController?.presentedViewController == self.navigationController)
            || self.tabBarController?.presentingViewController is UITabBarController
    }
    
    @IBAction public func dismiss(segue: UIStoryboardSegue) {
        if (self.traitCollection.userInterfaceIdiom == .pad) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

