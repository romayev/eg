//
//  EGEditCell.swift
//  EGKit
//
//  Created by Alex Romayev on 2/28/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

public protocol EGEditCell {
    func update()
    func cellWillDie()
}

public class EGEditCellBase: UITableViewCell, EGEditCell {
    public func update() {
    }
    public func cellWillDie() {
    }
}

public protocol EGPickerEditCellDelegate: class {
    var itemsForEditCell: [String]? { get }
    var selectedItemsForEditCell: [String]? { get }
    func editCellDidSelectValue(_ value: String, at index: Int)
}

public protocol EGAddPickerEditCellDelegate: class, EGPickerEditCellDelegate {
    func editCellDidAdd(value: String)
}

public protocol EGDatePickerEditCellDelegate: class {
    var dateForEditCell: Date { get set }
}

public protocol EGNotesEditCellDelegate: class {
    var notesForEditCell: String? { get set }
}

enum EGEditDropDownRow {
    enum State {
        case checked, unchecked
    }
    case add
    case normal(State)

    var accessoryType: UITableViewCellAccessoryType {
        switch self {
        case .add: return .disclosureIndicator
        case .normal(.checked): return .checkmark
        case .normal(.unchecked): return .none
        }
    }
    var reuseIdentifier: String {
        switch self {
        case .add: return "AddCell"
        case .normal: return "Cell"
        }
    }
}

// MARK: EGEditDropDownCell
public class EGEditDropDownCell: EGEditCellBase, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!

    public weak var delegate: EGPickerEditCellDelegate!
    var items: [String] = [String]()

    override open func awakeFromNib() {
        super.awakeFromNib()
        tableView.rowHeight = 44.0
    }

    public override func update() {
        guard let items = delegate.itemsForEditCell else {
            preconditionFailure("Failed to get items for drop down")
        }
        self.items = items
        tableView.reloadData()
    }

    // MARK: UITableViewDelegate, UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var row: EGEditDropDownRow
        var checked = false
        let title = items[indexPath.row]
        if let selected = delegate.selectedItemsForEditCell {
            checked = selected.contains(title)
        }
        row = checked ? .normal(.checked) : .normal(.unchecked)
        let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier, for: indexPath)
        cell.textLabel?.text = title
        cell.accessoryType = row.accessoryType
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
        delegate.editCellDidSelectValue(items[row], at: row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: EGEditDropDownAddCell
public class EGEditDropDownAddCell: EGEditDropDownCell {
    public weak var addDelegate: EGAddPickerEditCellDelegate!
    private func parentIndexPath(_ indexPath: IndexPath) -> IndexPath {
        var parentPath = indexPath
        parentPath.row = parentPath.row - 1
        return parentPath
    }
    private var addCell: EGEditAddCell!

    public override func cellWillDie() {
        addCell.willDie()
    }

    // MARK: UITableViewDelegate, UITableViewDataSource
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.tableView(tableView, numberOfRowsInSection: section) + 1
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var row: EGEditDropDownRow
        if (indexPath.row == 0) {
            row = .add
            let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier, for: indexPath) as! EGEditAddCell
            addCell = cell
            cell.titleLabel.text = NSLocalizedString("enter-new", comment: "")
            cell.textField.placeholder = NSLocalizedString("booking.enter-project-code", comment: "")
            cell.delegate = addDelegate
            cell.accessoryType = row.accessoryType
            return cell
        } else {
            var newPath = indexPath
            newPath.row = newPath.row - 1
            return super.tableView(tableView, cellForRowAt: parentIndexPath(indexPath))
        }
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            let cell = tableView.cellForRow(at: indexPath) as! EGEditAddCell
            cell.toggleState()
            tableView.deselectRow(at: indexPath, animated: false)
        } else {
            super.tableView(tableView, didSelectRowAt: parentIndexPath(indexPath))
        }
    }
}

public class EGEditAddCell: UITableViewCell, UITextFieldDelegate {
    enum State {
        case view, add
    }
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textField: UITextField!
    public weak var delegate: EGAddPickerEditCellDelegate!
    var state: State = .view

    func toggleState() {
        switch state {
        case .view:
            state = .add
            textField.isHidden = false
            titleLabel.isHidden = true
            textField.becomeFirstResponder()
        case .add:
            state = .view
            textField.isHidden = true
            titleLabel.isHidden = false
        }
    }

    func willDie() {
        if state == .add {
            if let text = textField.text {
                if (!text.isEmpty) {
                    delegate.editCellDidAdd(value: text)
                }
            }
            toggleState()
        }
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text {
            if (!text.isEmpty) {
                delegate.editCellDidAdd(value: text)
            }
        }
        return false
    }
}

// MARK: EGEditDatePickerCell
public class EGEditDatePickerCell: EGEditCellBase {
    @IBOutlet weak var datePicker: UIDatePicker!

    public weak var delegate: EGDatePickerEditCellDelegate!

    public override func update() {
        datePicker.date = delegate.dateForEditCell
    }

    @IBAction func valueDidChange(_ sender: UIDatePicker) {
        delegate.dateForEditCell = sender.date
    }
}

// MARK: EGEditPickerCell
public class EGEditPickerCell: EGEditCellBase, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet var picker: UIPickerView!

    public weak var delegate: EGPickerEditCellDelegate!

    var items: [String] = [String]()

    public override func update() {
        precondition(delegate.itemsForEditCell != nil, "EGEditPickerCell requires items")
        guard let items = delegate?.itemsForEditCell else {
            preconditionFailure("EGEditPickerCell requires items")
        }
        assert(items.count > 0, "EGEditPickerCell requires at least one item")

        self.items = items
        picker.reloadAllComponents()
        if let selected = delegate?.selectedItemsForEditCell?.first {
            guard let row = items.index(of: selected) else {
                print("WARNING: item '\(selected)' is not found in \(items)")
                return
            }
            picker.selectRow(row, inComponent: 0, animated: false)
        }
    }

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row]
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate.editCellDidSelectValue(items[row], at: row)
    }
}

// MARK: EGEditNotesCell
public class EGEditNotesCell: EGEditCellBase, UITextViewDelegate {
    @IBOutlet var textView: UITextView!

    public weak var delegate: EGNotesEditCellDelegate!

    public func textViewDidChange(_ textView: UITextView) {
        delegate.notesForEditCell = textView.text
    }
    public override func update() {
        textView.text = delegate.notesForEditCell
        textView.becomeFirstResponder()
    }
}
