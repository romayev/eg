//
//  DropDownCell.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/18/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import UIKit

public protocol DropDownCellDelegate: class {
    var dropDownItems: [String]? { get }
    var selectedItems: [String]? { get }
    func cell(_ cell: UITableViewCell, didSelectValue value: String, atIndex index: Int)
}

open class DropDownCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    public weak var delegate: DropDownCellDelegate?
    var items: [String] = [String]()
    @IBOutlet var tableView: UITableView!

    override open func awakeFromNib() {
        super.awakeFromNib()
        tableView.rowHeight = 44.0
    }

    public func update() {
        guard let items = delegate?.dropDownItems else {
            assertionFailure("Failed to get items for drop down")
            return
        }
        self.items = items
        tableView.reloadData()
    }

    // MARK: UITableViewDelegate, UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let selected = delegate?.selectedItems {
            let title = items[indexPath.row]
            let checked = selected.contains(title)
            cell.textLabel?.text = title
            cell.accessoryType = checked ? .checkmark : .none
        }

        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let all = row == 0
        for (other, _) in self.items.enumerated() {
            let otherPath = NSIndexPath(row: other, section: 0)
            if let cell = tableView.cellForRow(at: otherPath as IndexPath) {
                let checked = (all && other == 0) || (!all && other == row)
                cell.accessoryType = checked ? .checkmark : .none
            }
        }
        delegate?.cell(self, didSelectValue: items[row], atIndex: row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
