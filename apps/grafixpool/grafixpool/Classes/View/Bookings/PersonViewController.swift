//
//  PersonEditViewController.swift
//  grafixpool
//
//  Created by Alex Romayev on 3/11/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import EGKit
import CoreData

protocol PersonViewControllerDelegate: class {
    func personControllerDidChangeState(_ state: PersonViewController.State)
}

class PersonViewController: EGViewController {
    enum State {
        case add, edit, view

        func update(_ c: PersonViewController) {
            switch self {
            case .add:
                c.readView.isHidden = true
                c.editView.isHidden = false
                c.firstNameTextField.becomeFirstResponder()
                c.saveButton.isEnabled = c.isSaveEnabled
            case .edit:
                guard let person = c.person else {
                    preconditionFailure("No person")
                }
                c.readView.isHidden = true
                c.editView.isHidden = false
                c.firstNameTextField.text = person.firstName
                c.lastNameTextField.text = person.lastName
                c.firstNameTextField.becomeFirstResponder()
                c.saveButton.isEnabled = c.isSaveEnabled
            case .view:
                c.readView.isHidden = false
                c.editView.isHidden = true
                c.firstNameTextField.resignFirstResponder()
                c.lastNameTextField.resignFirstResponder()

                guard let person = c.person else {
                    preconditionFailure("No person")
                }
                c.personNameLabel.text = "\(person.lastName!), \(person.firstName!)"
            }
        }
    }

    @IBOutlet var readView: UIView!
    @IBOutlet var editView: UIStackView!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var personNameLabel: UILabel!
    @IBOutlet var editButton: UIButton!

    let editingContext = DataStore.store.editingContext
    var person: Person?
    var state: State = .view {
        didSet {
            delegate.personControllerDidChangeState(state)
        }
    }
    public weak var delegate: PersonViewControllerDelegate!

    private var isSaveEnabled: Bool {
        guard let firstText = firstNameTextField.text else {
            preconditionFailure("firstNameTextField is not connected")
        }
        guard let lastText = lastNameTextField.text else {
            preconditionFailure("lastNameTextField is not connected")
        }
        return !firstText.isEmpty && !lastText.isEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        firstNameTextField.placeholder = NSLocalizedString("person.edit.first-name-placeholder", comment: "")
        lastNameTextField.placeholder = NSLocalizedString("person.edit.first-name-placeholder", comment: "")
        saveButton.setTitle(NSLocalizedString("ok", comment: ""), for: .normal)
        editButton.setTitle(NSLocalizedString("edit", comment: ""), for: .normal)

        if let person = Person.defaultPerson(editingContext) {
            self.person = person
            state = .view
        } else {
            self.person = Person(context: editingContext)
            state = .add
        }
        state.update(self)
    }

    @IBAction func textFieldTextDidChange() {
        saveButton.isEnabled = isSaveEnabled
    }

    @IBAction func edit(_ sender: UIButton) {
        state = .edit
        state.update(self)
    }

    @IBAction func save(_ sender: UIButton) {
        guard let person = self.person else {
            preconditionFailure("No person")
        }

        person.firstName = firstNameTextField.text
        person.lastName = lastNameTextField.text
        DataStore.store.save(editing: editingContext)
        state = .view
        state.update(self)
    }
}
