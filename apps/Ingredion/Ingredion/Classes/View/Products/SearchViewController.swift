//
//  SearchViewController.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/13/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import UIKit

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

class SearchViewController : ViewController, UITableViewDelegate, UITableViewDataSource, DropDownCellDelegate, ProductsViewControllerDelegate, ExpertsViewControllerDelegate {
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var productCountLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var viewButton: UIButton!

    var searchCriteria: SearchCriteria = SearchCriteria()
    //var dropDownOptions: DropDownValues?
    var editorPath: IndexPath?
    var activeCellPath: IndexPath? {
        if let editorPath = self.editorPath {
            return IndexPath(item: editorPath.row - 1, section: editorPath.section)
        }
        return nil
    }

    weak var delegate: SearchViewControllerDelegate?

    // MARK: DropDownCellDelegate - vars
    var dropDownItems: [String]? {
        guard let activeRow = activeCellPath?.row else  {
            print("ERROR: Active cell undefined")
            return nil
        }
        let attribute = searchCriteria.attributes[activeRow]
        return productType.dropDownValuesFor(attribute: attribute, in: searchCriteria)
    }
    var selectedItems: [String]? {
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
    var productType: ProductType = .beverages
    var products: [Product] = []

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()

        // Localize
        navigationItem.title = productType.localizedName
        productImageView.image = UIImage(named: productType.imageName)
        resetButton.setTitle(NSLocalizedString("reset", comment: ""), for: .normal)
        viewButton.setTitle(NSLocalizedString("view", comment: ""), for: .normal)
        headerLabel.text = NSLocalizedString("product-count", comment: "")

        productType = (delegate?.productType)!
        searchCriteria = SearchCriteria(attributes: productType.searchAttributes)
        searchCriteriaDidChange(reset: true)
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

    // MARK: UITableViewDataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = productType.searchAttributes.count
        if let editorSection = editorPath?.section {
            let editor = section == editorSection ? 1 : 0
            return count + editor
        }
        return count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == editorPath {
            if let count = dropDownItems?.count {
                return 44.0 * CGFloat(count)
            }

        }
        return 44.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var row = indexPath.row
        if (indexPath == editorPath) {
            let cellIdentifier = "DropDown"
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DropDownCell {
                cell.delegate = self
                cell.update()
                return cell
            }
        }
        if let editorPath = self.editorPath {
            if indexPath.section == editorPath.section && row > editorPath.row {
                row -= 1
            }
        }
        
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

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if (editorPath != nil) {
            return indexPath.section != editorPath?.section || indexPath.row != editorPath?.row
        }
        return true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        var row = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)

        var edit = false
        if let editorPath = self.editorPath {
            self.editorPath = nil
            tableView.deleteRows(at: [editorPath], with: .fade)
            if section == editorPath.section && indexPath.row > editorPath.row {
                row -= 1
            }
            edit = (section != editorPath.section) || (row + 1) != editorPath.row
        } else {
            edit = true
        }

        if edit {
            self.editorPath = IndexPath(item: row + 1, section: section)
            if let editorPath = self.editorPath {
                tableView.insertRows(at: [editorPath], with: .fade)
            }
            if let activeCellPath = self.activeCellPath {
                tableView.scrollToRow(at: activeCellPath, at: .none, animated: true)
            }
        }
    }

    // MARK: DropDownCellDelegate - funcs
    func cell(_ cell: UITableViewCell, didSelectValue value: String, atIndex index: Int) {
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
        let filterCriteria = searchCriteria
        products = productType.productsWithSearchCriteria(filterCriteria)
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
