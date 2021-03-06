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

class SearchViewController : EGEditTableViewController, EGSegueHandlerType, ProductsViewControllerDelegate, ExpertsViewControllerDelegate {
    enum EGSegueIdentifier: String {
        case products, experts
    }

    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var productCountLabel: UILabel!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var viewButton: UIButton!

    var searchCriteria: SearchCriteria!

    weak var delegate: SearchViewControllerDelegate?

    override var count: Int { return productType.searchAttributes.count }

    // MARK: EGEditDropDownCellDelegate - vars
    override var itemsForEditCell: [String]? {
        guard let activeRow = activePath?.row else  {
            print("ERROR: Active cell undefined")
            return nil
        }
        let attribute = searchCriteria.attributes[activeRow]
        return productType.dropDownValues(for: attribute, in: searchCriteria)
    }
    override var selectedItemsForEditCell: [String]? {
        guard let activeCellPath = self.activePath else {
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
        resetButton.setTitle("reset".localized, for: .normal)
        viewButton.setTitle("view".localized, for: .normal)
        headerLabel.text = "product-count".localized

        searchCriteria = SearchCriteria(attributes: productType.searchAttributes)
        searchCriteriaDidChange(reset: true)

        tableView.tableFooterView = UIView()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            fatalError("Invalid segue identifier \(String(describing: segue.identifier))")
        }
        guard let segueIdentifier = EGSegueIdentifier(rawValue: identifier) else {
            fatalError("Invalid segue identifier \(identifier)")
        }
        switch segueIdentifier {
        case .products:
            if let c = segue.destination as? ProductsViewController {
                c.delegate = self
            }
        case .experts:
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

    override func cell(atAdjusted indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(productType.rawValue).search.title.\(indexPath.row)".localized
        cell.detailTextLabel?.text = self.descriptionForRow(indexPath.row)
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
    override func editCellDidSelectValue(_ value: String, at index: Int) {
        if let activeCellPath = self.activePath {
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
                tableView.reloadData()
                if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows {
                    tableView.reloadRows(at: indexPathsForVisibleRows, with: .automatic)
                }
            }
        }
    }

    // MARK: Private
    private func reloadAllRows(row: Int) -> Bool {
        var reloadAll = false
        if let activeCellRow = activePath?.row {
            if (productType == .beverages && activeCellRow == 1) { // Segment
                if searchCriteria.valuesForAttributeAtIndex(activeCellRow) == nil { // Segment not selected
                    reloadAll = true
                }
            }
        }
        return reloadAll
    }

    private func searchCriteriaDidChange(reset: Bool = false) {
        products = productType.products(with: searchCriteria)
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
