//
//  ContactViewController.swift
//  grafixpool
//
//  Created by Alex Romayev on 3/15/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import UIKit
import EGKit

class ContactViewController: EGViewController {
    @IBOutlet var title1Label: UILabel!
    @IBOutlet var title2Label: UILabel!
    @IBOutlet var textView1: UITextView!
    @IBOutlet var textView2: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "contact".localized
        var inset = textView1.contentInset
        inset.left -= 6
        inset.right -= 6
        textView1.contentInset = inset
        textView2.contentInset = inset
    }
}
