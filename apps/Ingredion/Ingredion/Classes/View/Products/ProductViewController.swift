//
//  ProductViewController.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/20/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import UIKit
import EGKit

class ProductAttributeCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var detailLabel: UILabel?
}

class ProductViewController: EGViewController, UITableViewDataSource {
    @IBOutlet var tableView: UITableView?
    var product: Product?
    var attributes: [String]?

    enum CellId: String {
        case productName = "ProductNameCell"
        case noDetail = "ProductNameNoDetailCell"
        case productAttribute = "ProductAttributeCell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 100
        tableView?.alwaysBounceVertical = false

        if let attributes = product?.productType.displayAttributes {
            self.attributes = attributes.filter({ product?.value(forKey: $0) != nil})
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = product?.name
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.reloadData()
    }

    // MARK UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = attributes?.count {
            return count + 1
        }
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row

        var identifier: CellId;
        switch row {
        case 0 where (product?.detail?.isEmpty)!:
            identifier = .noDetail
        case 0:
            identifier = .productName
        default:
            identifier = .productAttribute
        }

        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath) as? ProductAttributeCell {
            switch row {
            case 0:
                cell.titleLabel?.text = product?.name
                cell.detailLabel?.text = product?.detail
            default:
                if let attribute = attributes?[row - 1] {
                    cell.titleLabel?.text = NSLocalizedString("product.attribute." + attribute, comment: "")
                    cell.detailLabel?.text = product?[attribute]
                }
            }
            return cell
        }
        return ProductAttributeCell()
    }
}
