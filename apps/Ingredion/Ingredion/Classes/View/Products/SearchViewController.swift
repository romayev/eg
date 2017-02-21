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

class SearchViewController : ViewController, DropDownCellDelegate, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: SearchViewControllerDelegate?

    // MARK: DropDownCellDelegate
    var editorItems: Array<String>? {
        if let editorRow = editorPath?.row {
            if (editorRow - 1 >= availableValues.count) {
                return nil
            }
            return availableValues[editorRow - 1]
        }
        return nil
    }

    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var productCountLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var viewButton: UIButton!

    var criteria = [String]()
    var availableValues = [[String]]()
    var selectedValues = [[String]]()
    var productType: ProductType = .beverages
    var products: [Product]?
    var count = 0
    var editorPath: IndexPath? = nil
    var editorParentPath: IndexPath? {
        if let editorPath = self.editorPath {
            return IndexPath(item: editorPath.row - 1, section: editorPath.section)
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = nil
        resetButton.setTitle(NSLocalizedString("reset", comment: "reset"), for: .normal)
        viewButton.setTitle(NSLocalizedString("view", comment: "view"), for: .normal)
        productType = (delegate?.productType)!
        initializeSearch()
        update()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // FIXME: Implement
//        if (segue.identifier == "products") {
//        }
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
            if let count = editorItems?.count {
                return 44.0 * CGFloat(count)
            }

        }
        return 44.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var row = indexPath.row
        if (indexPath == editorPath) {
            let cellIdentifier = "DropDown"
            let cell: DropDownCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DropDownCell
            cell.delegate = self
            cell.update()
            return cell
        }
        if (indexPath == editorPath) {
            row -= 1
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = productType.localizedName
        cell.detailTextLabel?.text = self.descriptionFor(row: row)

        if let productType = ProductType(rawValue: indexPath.row) {
            if (productType.implemented) {
                cell.textLabel?.alpha = 1.0
                cell.detailTextLabel?.alpha = 1.0
                cell.isUserInteractionEnabled = true
            } else {
                cell.textLabel?.alpha = 0.5
                cell.detailTextLabel?.alpha = 0.5
                cell.isUserInteractionEnabled = false
            }
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
        var row = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)

        if let editorPath = self.editorPath {
            self.editorPath = nil
            tableView.deleteRows(at: [editorPath], with: .fade)
            if indexPath.section == editorPath.section && indexPath.row > editorPath.row {
                row -= 1
            }
        } else {
            let editorPath = IndexPath(item: row + 1, section: indexPath.section)
            self.editorPath = editorPath
            tableView.insertRows(at: [editorPath], with: .fade)
            if let editorParentPath = self.editorParentPath {
                tableView.scrollToRow(at: [editorParentPath.row], at: .none, animated: true)
            }
        }

        // FIXME: Do I need this:
//        BOOL edit = NO;
//        edit = (section != editorSection || (row + 1) != editorRow);

    }

    // MARK: DropDownCellDelegate
    func selectedItemsForCell(cell: UITableViewCell) -> [String]? {
        if let editorPath = self.editorPath {
            return selectedValues[editorPath.row - 1]
        }
        return nil
    }

    func cell(_ cell: UITableViewCell, didSelectCellAtRow row: NSInteger) {
        if let editorParentPath = self.editorParentPath {
            let reloadAll = processSelected(row: row, at: editorParentPath.row)
            for i in 0..<count where i != editorParentPath.row {
                updateAvailableValuesAt(index: i)
            }
            if (reloadAll) {
                tableView.reloadData()
            } else {
                if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows {
                    tableView.reloadRows(at: indexPathsForVisibleRows, with: .automatic)
                }
            }
        }
        updateProducts()
    }

    // MARK: Private
    private func processSelected(row: Int, at index: Int) -> Bool {
        var reloadAll = false

        let availableValues = self.availableValues[index]
        var selectedArray = selectedValues[index]
        let selectedValue = availableValues[row]

        if selectedValue == "All" {
            selectedArray.removeAll()
            selectedArray.append("All")
        } else {
            selectedArray.remove(object: "All")
            if selectedArray.contains(selectedValue) {
                selectedArray.remove(object: selectedValue)
            } else {
                selectedArray.append(selectedValue)
            }
            if selectedArray.isEmpty || selectedArray.count == availableValues.count {
                selectedArray.removeAll()
                selectedArray.append("All")
            }
        }
        if (productType == .beverages && index == 1) { // Segment
            if (selectedArray.count == 1 && selectedArray.first == "All") {
                reloadAll = true
                for i in 2..<count {
                    selectedArray = selectedValues[i]
                    selectedArray.removeAll()
                    selectedArray.append("All")
                }
            }
        }

        return reloadAll
    }

    private func initializeSearch() {
        products = productType.products
        criteria = productType.searchCriteria
        count = criteria.count
        productCountLabel.text = "\(products?.count)"

        availableValues = createArrayOfArrays()
        selectedValues = createArrayOfArrays(withAll: true)
        for idx in 0..<count {
            updateAvailableValuesAt(index: idx)
        }
    }

    private func update() {
        navigationItem.title = NSLocalizedString("index.title.\(productType)", comment: "index.title.\(productType)")
        productImageView.image = UIImage(named: "search-\(productType)")
        headerLabel.text = NSLocalizedString("product-count", comment: "product-count")
    }

    private func updateProducts() {
        var searchCriteria: [String: [String]] = Dictionary()
        for idx in 0..<count {
            searchCriteria[criteria[idx]] = selectedValues[idx]
        }
        products = productType.productsWithSearchCriteria(searchCriteria)
        headerLabel.text = NSLocalizedString("product-count", comment: "product-count")
        productCountLabel.text = "\(products?.count)"
        viewButton.setTitle(NSLocalizedString("view", comment: "view"), for: .normal)
    }

    // MARK: Helpers
    private func createArrayOfArrays(withAll all: Bool = false) -> [[String]] {
        var array = [[String]]()
        for idx in 0..<count {
            array[idx] = all ? ["All"] : [String]()
        }
        return array
    }

    private func descriptionFor(row: Int) -> String {
        return selectedValues[row].joined(separator: ", ")
        return ""
    }

    private func isCellEnabledAt(indexPath: IndexPath) -> Bool {
        if (productType == .beverages) {
            let segmentRowIdx = (editorPath == nil) ? 2 : 3
            let selectedSegments = selectedValues[1]
            if (selectedSegments.count == 1 && selectedSegments.first == "All") {
                return indexPath.row < segmentRowIdx
            }
        }
        return true
    }

    private func updateAvailableValuesAt(index: Int) {
        let currentCriteria = criteria[index]

        // Create a dictionary of criteria that includes all other selected values
        var searchCriteria: [String: [String]] = Dictionary()
        for idx in 0..<count where idx != index {
            searchCriteria[currentCriteria] = selectedValues[idx]
        }
        // Update available values at the passed in index
        let filteredProducts = productType.productsWithSearchCriteria(searchCriteria)
        availableValues[index] = productType.propertyValues(currentCriteria, in: filteredProducts)
    }
}
