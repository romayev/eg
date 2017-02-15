//
//  ViewController.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/13/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import UIKit

class ViewController : UIViewController {
    
    @IBAction func dismiss(segue: UIStoryboardSegue) {
        if (self.traitCollection.userInterfaceIdiom == .pad) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
