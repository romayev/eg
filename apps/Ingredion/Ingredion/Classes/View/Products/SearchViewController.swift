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
    weak var delegate: SearchViewControllerDelegate?

    // MARK: DropDownCellDelegate
    var dropDownItems: [String]? {
        if let activeRow = activeCellPath?.row {
            if (activeRow >= dropDownOptions.count) {
                return nil
            }
            return dropDownOptions[activeRow]
        }
        return nil
    }

    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var productCountLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var viewButton: UIButton!

    // MARK: ProductsViewControllerDelegate
    var productType: ProductType = .beverages
    var products: [Product] = []
    
    var searchAttributes = [String]()
    var searchCriteria: SearchCriteria = SearchCriteria()
    var dropDownOptions = [[String]]()
    var count = 0
    var editorPath: IndexPath? = nil
    var activeCellPath: IndexPath? {
        if let editorPath = self.editorPath {
            return IndexPath(item: editorPath.row - 1, section: editorPath.section)
        }
        return nil
    }
    var selectedValuesForCurrentDropDown: [String]? {
        guard let activeCellPath = self.activeCellPath else {
            return nil
        }
        if let selectedValues = searchCriteria.valuesForAttributeAtIndex(activeCellPath.row) {
            return selectedValues
        } else {
            return ["All"]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        resetButton.setTitle(NSLocalizedString("reset", comment: "reset"), for: .normal)
        viewButton.setTitle(NSLocalizedString("view", comment: "view"), for: .normal)
        headerLabel.text = NSLocalizedString("product-count", comment: "product-count")

        productType = (delegate?.productType)!
        searchAttributes = productType.searchAttributes
        searchCriteria = SearchCriteria(attributes: productType.searchAttributes)
        count = productType.searchAttributes.count
        initializeSearch()
        update()
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
    @IBAction func reset(sender: Any) {
        initializeSearch()
        editorPath = nil
        tableView.reloadData()
    }

    // MARK: UITableViewDataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let editorSection = editorPath?.section {
            let editor = section == editorSection ? 1 : 0
            return self.count + editor
        }
        return self.count
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

        cell.textLabel?.text = self.titleForRow(row)
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

    // MARK: DropDownCellDelegate
    func selectedItemsForCell(cell: UITableViewCell) -> [String]? {
        return selectedValuesForCurrentDropDown
    }

    func cell(_ cell: UITableViewCell, didSelectCellAtRow row: NSInteger) {
        if let activeCellPath = self.activeCellPath {
            let attributeIndex = activeCellPath.row
            let attribute = searchAttributes[attributeIndex]
            searchCriteria.toggleValueForAttribute(attribute, value: dropDownOptions[attributeIndex][row])
            updateProducts()

            for i in 0..<count where i != activeCellPath.row {
                updateAvailableValuesAt(index: i)
            }

            let reloadAll = processSelected(row: row, at: activeCellPath.row)
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
    private func processSelected(row: Int, at index: Int) -> Bool {
        var reloadAll = false
        if (productType == .beverages && index == 1) { // Segment
            if searchCriteria.valuesForAttributeAtIndex(index) == nil {
                reloadAll = true
            }
        }
        return reloadAll
    }

    private func initializeSearch() {
        updateProducts()
        dropDownOptions = createAvailableValues()
        for idx in 0..<count {
            updateAvailableValuesAt(index: idx)
        }
    }

    private func update() {
        navigationItem.title = productType.localizedName
        productImageView.image = UIImage(named: productType.imageName)
    }

    private func updateProducts() {
        products = productType.productsWithSearchCriteria(searchCriteria)
        productCountLabel.text = "\(products.count)"
        viewButton.setTitle(NSLocalizedString("view", comment: "view"), for: .normal)
    }

    // MARK: Helpers
    private func createAvailableValues() -> [[String]] {
        var array = [[String]]()
        for _ in 0..<count {
            array.append(["All"])
        }
        return array
    }

    private func titleForRow(_ row: Int) -> String {
        let key = productType.module + ".search.title.\(row)"
        return NSLocalizedString(key, comment: "")
    }

    private func descriptionForRow(_ row: Int) -> String {
        if let selectedValues = searchCriteria.valuesForAttributeAtIndex(row) {
            return selectedValues.joined(separator: ", ")
        } else {
            return "All"
        }
    }

    private func isCellEnabledAt(indexPath: IndexPath) -> Bool {
        if (productType == .beverages) {
            let segmentRowIdx = (editorPath == nil) ? 2 : 3
            if let activeCellPath = self.activeCellPath {
                if (searchCriteria.valuesForAttributeAtIndex(activeCellPath.row)) == nil {
                    return indexPath.row < segmentRowIdx
                }
            }
        }
        return true
    }

    private func updateAvailableValuesAt(index: Int) {
        dropDownOptions[index] = productType.dropDownValues(property: searchAttributes[index], in: products)
    }
}
