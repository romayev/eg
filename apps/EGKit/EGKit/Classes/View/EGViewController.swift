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
    
    @IBAction public func dismiss(segue: UIStoryboardSegue) {
        if (self.traitCollection.userInterfaceIdiom == .pad) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

