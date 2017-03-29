//
//  IndexViewController.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/13/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import UIKit
import EGKit

class IndexViewController: EGViewController, EGSegueHandlerType, UITableViewDelegate, UITableViewDataSource, SearchViewControllerDelegate {
    enum EGSegueIdentifier: String {
        case search
    }

    @IBOutlet var tableView: UITableView!

    // MARK: SearchViewControllerDelegate
    var productType: ProductType = .beverages

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "index.title".localized
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
        guard let identifier = segue.identifier else {
            fatalError("Invalid segue identifier \(segue.identifier)")
        }
        guard let segueIdentifier = EGSegueIdentifier(rawValue: identifier) else {
            fatalError("Invalid segue identifier \(identifier)")
        }
        switch segueIdentifier {
        case .search:
            let n = segue.destination as! UINavigationController
            let c = n.topViewController as! SearchViewController
            c.delegate = self
        }
    }

    // MARK: UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProductType.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let label = cell.viewWithTag(100) as? UILabel {
            let productType: ProductType = ProductType.all[indexPath.row]
            label.text = productType.localizedName
            if !productType.implemented {
                cell.isUserInteractionEnabled = false
                label.alpha = 0.5
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showProductController(ProductType.all[indexPath.row])
    }

    func showProductController(_ type: ProductType, animated: Bool = true) {
        productType = type
        guard let index = ProductType.all.index(of: productType) else {
            fatalError()
        }
        let indexPath = IndexPath(item: index, section: 0)
        if let selectedPath = tableView.indexPathForSelectedRow {
            if (indexPath != selectedPath) {
                tableView.selectRow(at: indexPath, animated: animated, scrollPosition: .none)
            }
        }
        if (!productType.implemented) {
            productType = .confectionery
        }
        self.performSegue(withIdentifier: "search", sender: nil)
    }
}
