//
//  SearchViewController.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/13/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import UIKit
import EGKit

extension Array where Element: Equatable {
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}

protocol SearchViewControllerDelegate: class {
    var productType: ProductType { get }
}

class SearchViewController : EGEditTableViewController, ProductsViewControllerDelegate, ExpertsViewControllerDelegate {
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var productCountLabel: UILabel!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var viewButton: UIButton!

    var searchCriteria: SearchCriteria!

    weak var delegate: SearchViewControllerDelegate?

    override var count: Int { return productType.searchAttributes.count }

    // MARK: EGEditDropDownCellDelegate - vars
    override var dropDownItems: [String]? {
        guard let activeRow = activeCellPath?.row else  {
            print("ERROR: Active cell undefined")
            return nil
        }
        let attribute = searchCriteria.attributes[activeRow]
        return productType.dropDownValuesFor(attribute: attribute, in: searchCriteria)
    }
    override var selectedItems: [String]? {
        guard let activeCellPath = self.activeCellPath else {
            return nil
        }
        if let selectedValues = searchCriteria.valuesForAttributeAtIndex(activeCellPath.row) {
            return selectedValues
        } else {
            return [SearchCriteria.ALL()]
        }
    }

    // MARK: ProductsViewControllerDelegate - vars
    var productType: ProductType!
    var products: [Product]!

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        productType = (delegate?.productType)!

        // Localize
        navigationItem.title = productType.localizedName
        productImageView.image = UIImage(named: productType.imageName)
        resetButton.setTitle(NSLocalizedString("reset", comment: ""), for: .normal)
        viewButton.setTitle(NSLocalizedString("view", comment: ""), for: .normal)
        headerLabel.text = NSLocalizedString("product-count", comment: "")

        searchCriteria = SearchCriteria(attributes: productType.searchAttributes)
        searchCriteriaDidChange(reset: true)

        tableView.tableFooterView = UIView()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier
        if identifier == "products" {
            if let c = segue.destination as? ProductsViewController {
                c.delegate = self
            }
        } else if identifier == "experts" {
            if let c = (segue.destination as? UINavigationController)?.topViewController as? ExpertsViewController {
                c.delegate = self
            }
        }
    }

    // MARK: UI Actions
    @IBAction func reset(_ sender: Any) {
        searchCriteria = SearchCriteria(attributes: productType.searchAttributes)
        searchCriteriaDidChange(reset: true)
        editorPath = nil
        tableView.reloadData()
    }

    override func cellFor(_ row: Int, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = NSLocalizedString(productType.module + ".search.title.\(row)", comment: "")
        cell.detailTextLabel?.text = self.descriptionForRow(row)
        if (isCellEnabledAt(indexPath: indexPath)) {
            cell.textLabel?.alpha = 1.0
            cell.detailTextLabel?.alpha = 1.0
            cell.isUserInteractionEnabled = true
        } else {
            cell.textLabel?.alpha = 0.5
            cell.detailTextLabel?.alpha = 0.5
            cell.isUserInteractionEnabled = false
        }
        return cell
    }

    // MARK: EGEditDropDownCellDelegate - funcs
    override func cell(_ cell: UITableViewCell, didSelectValue value: String, atIndex index: Int) {
        if let activeCellPath = self.activeCellPath {
            let attribute = productType.searchAttributes[activeCellPath.row]
            searchCriteria.toggleValueForAttribute(attribute, value: value)
            if (productType == .beverages && activeCellPath.row == 1 && value == SearchCriteria.ALL()) {
                searchCriteria.resetValuesAfter(attributeIndex: 1)
            }
            searchCriteriaDidChange()

            let reloadAll = reloadAllRows(row: index)
            if (reloadAll) {
                tableView.reloadData()
            } else {
                if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows {
                    tableView.reloadRows(at: indexPathsForVisibleRows, with: .automatic)
                }
            }
        }
    }

    // MARK: Private
    private func reloadAllRows(row: Int) -> Bool {
        var reloadAll = false
        if let activeCellRow = activeCellPath?.row {
            if (productType == .beverages && activeCellRow == 1) { // Segment
                if searchCriteria.valuesForAttributeAtIndex(activeCellRow) == nil { // Segment not selected
                    reloadAll = true
                }
            }
        }
        return reloadAll
    }

    private func searchCriteriaDidChange(reset: Bool = false) {
        products = productType.productsWithSearchCriteria(searchCriteria)
        productCountLabel.text = "\(products.count)"
    }

    // MARK: Helpers
    private func descriptionForRow(_ row: Int) -> String {
        if let selectedValues = searchCriteria.valuesForAttributeAtIndex(row) {
            return selectedValues.joined(separator: ", ")
        } else {
            return SearchCriteria.ALL()
        }
    }

    private func isCellEnabledAt(indexPath: IndexPath) -> Bool {
        if (productType == .beverages) {
            let segmentRowIdx = (editorPath == nil) ? 2 : 3
            let segmentCriteria = searchCriteria.valuesForAttributeAtIndex(1)
            if segmentCriteria == nil {
                return indexPath.row < segmentRowIdx
            }
        }
        return true
    }
}
