//
//  DropDownCell.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/18/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import UIKit

protocol DropDownCellDelegate: class {
    var dropDownItems: [String]? { get }
    var selectedItems: [String]? { get }
    func cell(_ cell: UITableViewCell, didSelectValue value: String, atIndex index: Int)
}

class DropDownCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    weak var delegate: DropDownCellDelegate?
    var items: [String] = [String]()
    @IBOutlet var tableView: UITableView!

    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.rowHeight = 44.0
    }

    func update() {
        if let items = delegate?.dropDownItems {
            self.items = items
        }
        tableView.reloadData()
    }

    // MARK: UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let selected = delegate?.selectedItems {
            let title = items[indexPath.row]
            let checked = selected.contains(title)
            cell.textLabel?.text = title
            cell.accessoryType = checked ? .checkmark : .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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