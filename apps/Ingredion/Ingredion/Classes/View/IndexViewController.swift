//
//  IndexViewController.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/13/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import UIKit

class IndexViewController: ViewController, UITableViewDelegate, UITableViewDataSource, SearchViewControllerDelegate {
    @IBOutlet var tableView: UITableView!

    // MARK: SearchViewControllerDelegate
    var productType: Product.ProductType = .beverages

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("index.title", comment: "index.title")
        tableView.tableFooterView = nil
        if (self.traitCollection.userInterfaceIdiom == .pad) {
            showProductController(.beverages, animated: false)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (self.traitCollection.userInterfaceIdiom == .phone) {
            if let indexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "search" {
            let n = segue.destination as! UINavigationController
            let c = n.topViewController as! SearchViewController
            c.delegate = self
        }
    }

    // MARK: UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Product.ProductType.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let label = cell.viewWithTag(100) as? UILabel {
            let key = "index.title \(indexPath.row)"
            label.text = NSLocalizedString(key, comment: key)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let productType = Product.ProductType(rawValue: indexPath.row) {
            showProductController(productType)
        }
    }

    func showProductController(_ type: Product.ProductType, animated: Bool = true) {
        productType = type
        let indexPath = IndexPath(row: type.rawValue, section: 0)
        if let selectedPath = tableView.indexPathForSelectedRow {
            if (indexPath != selectedPath) {
                tableView.selectRow(at: indexPath, animated: animated, scrollPosition: .none)
            }
        }
        if (!productType.isImplemented()) {
            productType = .confectionery
        }
        self.performSegue(withIdentifier: "search", sender: nil)
    }
}
