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
    case dropDownAdd = "EGDropDownAdd"
    case date = "EGDate"
    case picker = "EGPicker"
    case notes = "EGNotes"

    var height: Double {
        switch self {
        case .dropDown, .dropDownAdd: return 44.0
        case .notes, .date, .picker: return 216.0
        }
    }
}

public struct EGEditTableState {
    public var activePath: IndexPath
    public var editorPath: IndexPath { return IndexPath(item: activePath.row + 1, section: activePath.section) }
    public func adjustedPath(forIndexPath indexPath: IndexPath) -> IndexPath {
        if indexPath.section == editorPath.section && indexPath.row >= editorPath.row {
            return IndexPath(item: indexPath.row - 1, section: indexPath.section)
        }
        return indexPath
    }
}

public enum EGCollapseState {
    case collapsed, edit(EGEditTableState)
    func count(_ count: Int) -> Int {
        switch self {
        case .collapsed:
            return count
        case .edit(let info):
            return count + 1
        }
    }
}


open class EGEditTableViewController: EGViewController, EGPickerEditCellDelegate, EGAddPickerEditCellDelegate, EGDatePickerEditCellDelegate, EGNotesEditCellDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet public var tableView: UITableView!

    public var editState: EGEditTableState?
    public var state: EGCollapseState = .collapsed

    // MARK: public vars
    public var editorPath: IndexPath?
    public var activePath: IndexPath? {
        if let editorPath = self.editorPath {
            return IndexPath(item: editorPath.row - 1, section: editorPath.section)
        }
        return nil
    }
    public func adjustedPath(forIndexPath indexPath: IndexPath) -> IndexPath {
        if let editorPath = editorPath {
            if indexPath.section == editorPath.section && indexPath.row >= editorPath.row {
                return IndexPath(item: indexPath.row - 1, section: indexPath.section)
            }
        }
        return indexPath
    }

    // MARK: open vars
    open var count: Int { return 0 }
    open var cellType: EGEditCellType { return .dropDown }

    // MARK: UITableViewDataSource & Delegate
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state.count(count)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath == editorPath) {
            let cell = editCellFor(cellType: cellType)
            return cell
        }
        return cell(atAdjusted: adjustedPath(forIndexPath: indexPath))
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
        case .dropDownAdd:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.rawValue, for: editorPath) as? EGEditDropDownAddCell else {
                preconditionFailure("Unable to deque a cell for cell type \(cellType)")
            }
            cell.delegate = self
            cell.addDelegate = self
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
            cell.delegate = self
            cell.update()
            return cell
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        var row = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)

        var edit = false
        if let editorPath = self.editorPath {
            let activeCellPath = self.activePath

            state = .collapsed
            editState = nil

            self.editorPath = nil
            let cell = tableView.cellForRow(at: editorPath) as! EGEditCell
            cell.cellWillDie()
            tableView.deleteRows(at: [editorPath], with: .fade)
            if section == editorPath.section && indexPath.row > editorPath.row {
                row -= 1
            }
            edit = (section != editorPath.section) || (row + 1) != editorPath.row
            editCellDidCollapse(at: activeCellPath!)
        } else {
            edit = true
        }

        if edit {
            self.editorPath = IndexPath(item: row + 1, section: section)
            editState = EGEditTableState(activePath: self.activePath!)
            if let editState = editState {
                state = .edit(editState)
                editorPath = editState.editorPath
                tableView.insertRows(at: [editState.editorPath], with: .fade)
            }

            if let activeCellPath = self.activePath {
                if (cellType == .notes) {
                    var inset = tableView.contentInset
                    let rect = tableView.rectForRow(at: indexPath)
                    inset.top -= rect.origin.y
                    UIView.animate(withDuration: 0.25, animations: { 
                        tableView.contentInset = inset
                    })
                }
                tableView.scrollToRow(at: activeCellPath, at: .none, animated: true)
            }
        } else {
            var inset = tableView.contentInset
            inset.top = 0
            UIView.animate(withDuration: 0.25, animations: {
                tableView.contentInset = inset
                tableView.reloadRows(at: [indexPath], with: .none)
            })
        }
    }

    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if (editorPath != nil) {
            return indexPath.section != editorPath?.section || indexPath.row != editorPath?.row
        }
        return true
    }

    open func cell(atAdjusted indexPath: IndexPath) -> UITableViewCell {
        preconditionFailure("This method must be overridden")
    }


    open var itemsForEditCell: [String]? { return [String]() }
    open var selectedItemsForEditCell: [String]? { return [String]() }

    open func editCellDidAdd(value: String) {
    }
    open func editCellDidSelectValue(_ value: String, at index: Int) {
    }
    open func editCellDidCollapse(at indexPath: IndexPath) {
    }

    open var notesForEditCell: String?

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == editorPath {
            switch cellType {
            case .dropDown:
                if let count = itemsForEditCell?.count {
                    return CGFloat(cellType.height) * CGFloat(count)
                }
            case .dropDownAdd:
                if let count = itemsForEditCell?.count {
                    return CGFloat(cellType.height) * CGFloat(count + 1)
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
