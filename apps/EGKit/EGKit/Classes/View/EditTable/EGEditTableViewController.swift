//
//  EGEditTableViewController.swift
//  EGKit
//
//  Created by Alex Romayev on 2/27/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import UIKit

open class EGEditTableViewController: EGViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet public var tableView: UITableView!

    // MARK: public vars
    public var editorPath: IndexPath?
    public var activeCellPath: IndexPath? {
        if let editorPath = self.editorPath {
            return IndexPath(item: editorPath.row - 1, section: editorPath.section)
        }
        return nil
    }

    // MARK: open vars
    open var count: Int { return 0 }


    open func initState() {
    }

    // MARK: UITableViewDataSource & Delegate
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let editorSection = editorPath?.section {
            let editor = section == editorSection ? 1 : 0
            return count + editor
        }
        return count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var row = indexPath.row
        if (indexPath == editorPath) {
            let cellIdentifier = "EGDropDown"
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? EGEditDropDownCell {
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
        return cellFor(row, at: indexPath)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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

    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if (editorPath != nil) {
            return indexPath.section != editorPath?.section || indexPath.row != editorPath?.row
        }
        return true
    }

    open func cellFor(_ row: Int, at indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension EGEditTableViewController: EGEditDropDownCellDelegate {
    open var dropDownItems: [String]? { return [String]() }
    open var selectedItems: [String]? { return [String]() }

    open func cell(_ cell: UITableViewCell, didSelectValue value: String, atIndex index: Int) {
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == editorPath {
            if let count = dropDownItems?.count {
                return 44.0 * CGFloat(count)
            }

        }
        return 44.0
    }
}
