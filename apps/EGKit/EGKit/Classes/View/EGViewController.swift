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
    public var isSimulator: Bool {
        #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(watchOS) || os(tvOS))
            return true
        #else
            return false
        #endif
    }
    @IBAction public func dismiss(segue: UIStoryboardSegue) {
        if (self.traitCollection.userInterfaceIdiom == .pad) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

