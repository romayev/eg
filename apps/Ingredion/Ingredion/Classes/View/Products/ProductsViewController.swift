//
//  ProductsViewController.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/20/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import UIKit
import EGKit

protocol ProductsViewControllerDelegate: class {
    var productType: ProductType! { get }
    var products: [Product]! { get }
}

class ProductsCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var detailLabel: UILabel?
}

class ProductsViewController: EGViewController, EGSegueHandlerType, ExpertsViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    enum EGSegueIdentifier: String {
        case product, experts
    }

    weak var delegate: ProductsViewControllerDelegate?

    // MARK: ExpertsViewControllerDelegate
    var productType: ProductType! {
        return (delegate?.productType)!
    }

    @IBOutlet var segmentedControlItem: UIBarButtonItem?
    @IBOutlet var segmentedControl: UISegmentedControl?
    @IBOutlet var tableView: UITableView?
    @IBOutlet var toolbar: UIToolbar?

    var products: [Product] = []
    var usePriority: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "products".localized
        segmentedControl?.setTitle("top".localized, forSegmentAt: 0)
        segmentedControl?.setTitle("all".localized, forSegmentAt: 1)

        if let productType = delegate?.productType {
            if !productType.usesPriority {
                if var items = toolbar?.items {
                    items.remove(object: segmentedControlItem!)
                    toolbar?.items = items
                }
            }
        }
        tableView?.tableFooterView = UIView()
        usePriority = productType.usesPriority
        loadProducts()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let indexPath = tableView?.indexPathForSelectedRow {
            tableView?.deselectRow(at: indexPath, animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            fatalError("Invalid segue identifier \(String(describing: segue.identifier))")
        }
        guard let segueIdentifier = EGSegueIdentifier(rawValue: identifier) else {
            fatalError("Invalid segue identifier \(identifier)")
        }
        switch segueIdentifier {
        case .product:
            if let indexPath = tableView?.indexPathForSelectedRow {
                let c: ProductViewController = segue.destination as! ProductViewController
                c.product = products[indexPath.row]
            }
        case .experts:
            let n: UINavigationController = segue.destination as! UINavigationController
            let c: ExpertsViewController = n.topViewController as! ExpertsViewController
            c.delegate = self
        }
    }

    // MARK: Actions
    @IBAction func toggleProducts(_ sender: UISegmentedControl) {
        loadProducts()
        tableView?.reloadData()
        tableView?.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
    }

    // MARK: Private
    private func loadProducts() {
        if let products = delegate?.products {
            if usePriority && segmentedControl?.selectedSegmentIndex == 0 {
                self.products = productType.highPriorityProducts(in: products)
            } else {
                self.products = products
            }
        }
    }

    // MARK: UITableViewDataSource & Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProductsCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ProductsCell
        let product = products[indexPath.row]
        cell.nameLabel?.text = product.name
        cell.detailLabel?.text = product.detail
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "product", sender: tableView.cellForRow(at: indexPath))
    }
}
