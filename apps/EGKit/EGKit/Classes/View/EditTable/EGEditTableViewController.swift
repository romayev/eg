//
//  EGEditTableViewController.swift
//  EGKit
//
//  Created by Alex Romayev on 2/27/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import UIKit

public enum EGEditCellType: String {
    case dropDown = "EGDropDown"
    case date = "EGDate"
    case picker = "EGPicker"
    case notes = "EGNotes"

    var height: Double {
        switch self {
        case .dropDown: return 44.0
        case .date: return 216.0
        case .picker: return 216.0
        case .notes: return 216.0
        }
    }
}

open class EGEditTableViewController: EGViewController, EGPickerEditCellDelegate, EGDatePickerEditCellDelegate, UITableViewDataSource, UITableViewDelegate {
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
    open var cellType: EGEditCellType { return .dropDown }


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
            let cell = editCellFor(cellType: cellType)
            return cell
        }
        if let editorPath = self.editorPath {
            if indexPath.section == editorPath.section && row > editorPath.row {
                row -= 1
            }
        }
        return cellFor(row, at: indexPath)
    }

    func editCellFor(cellType: EGEditCellType) -> UITableViewCell {
        guard let editorPath = self.editorPath else {
            preconditionFailure("Edit cell requested when editor path is not defined")
        }
        switch cellType {
        case .dropDown:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.rawValue, for: editorPath) as? EGEditDropDownCell else {
                preconditionFailure("Unable to deque a cell for cell type \(cellType)")
            }
            cell.delegate = self
            cell.update()
            return cell
        case .date:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.rawValue, for: editorPath) as? EGEditDatePickerCell else {
                fatalError("Unable to deque a cell for cell type \(cellType)")
            }

            cell.delegate = self
            cell.update()
            return cell
        case .picker:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.rawValue, for: editorPath) as? EGEditPickerCell else {
                fatalError("Unable to deque a cell for cell type \(cellType)")
            }
            cell.delegate = self
            cell.update()
            return cell
        case .notes:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.rawValue, for: editorPath) as? EGEditNotesCell else {
                fatalError("Unable to deque a cell for cell type \(cellType)")
            }
            return cell
        }
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
        preconditionFailure("This method must be overridden")
    }


    open var itemsForEditCell: [String]? { return [String]() }
    open var selectedItemsForEditCell: [String]? { return [String]() }

    open func editCellDidSelectValue(_ value: String, at index: Int) {
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == editorPath {
            switch cellType {
            case .dropDown:
                if let count = itemsForEditCell?.count {
                    return CGFloat(cellType.height) * CGFloat(count)
                }
            default:
                return CGFloat(cellType.height)
            }

        }
        return 44.0
    }

    open var dateForEditCell: Date {
        get {
            return Date()
        }
        set {
        }
    }
}
