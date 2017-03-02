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
}

public protocol EGPickerEditCellDelegate: class {
    var itemsForEditCell: [String]? { get }
    var selectedItemsForEditCell: [String]? { get }
    func editCellDidSelectValue(_ value: String, at index: Int)
}

public protocol EGDatePickerEditCellDelegate: class {
    var dateForEditCell: Date { get set }
}

// MARK: EGEditDropDownCell
public class EGEditDropDownCell: UITableViewCell, EGEditCell, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!

    public weak var delegate: EGPickerEditCellDelegate!
    var items: [String] = [String]()

    override open func awakeFromNib() {
        super.awakeFromNib()
        tableView.rowHeight = 44.0
    }

    public func update() {
        guard let items = delegate.itemsForEditCell else {
            preconditionFailure("Failed to get items for drop down")
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
        let title = items[indexPath.row]
        cell.textLabel?.text = title
        if let selected = delegate.selectedItemsForEditCell {
            let checked = selected.contains(title)
            cell.accessoryType = checked ? .checkmark : .none
        } else {
            cell.accessoryType = .none
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
        delegate.editCellDidSelectValue(items[row], at: row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

public class EGEditOptionalCell: UITableViewCell, EGEditCell {
    @IBOutlet weak var unknownButton: UIButton!

    @IBAction func toggleUnknown(_ sender: UIButton) {
    }
    public func update() {
        unknownButton.setTitle(NSLocalizedString("non", comment: ""), for: .normal)
    }
}

// MARK: EGEditDatePickerCell
public class EGEditDatePickerCell: EGEditOptionalCell {
    @IBOutlet weak var datePicker: UIDatePicker!

    public weak var delegate: EGDatePickerEditCellDelegate!

    public override func update() {
        datePicker.date = delegate.dateForEditCell
        print("update \(datePicker.date)")
    }

    @IBAction func valueDidChange(_ sender: UIDatePicker) {
        print("didChange \(sender.date)")
        delegate.dateForEditCell = sender.date
    }
}

// MARK: EGEditPickerCell
public class EGEditPickerCell: EGEditOptionalCell, UIPickerViewDataSource, UIPickerViewDelegate {
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
