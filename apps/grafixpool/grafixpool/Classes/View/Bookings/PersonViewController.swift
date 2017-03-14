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

class PersonViewController: EGViewController {
    enum ViewState {
        case add, edit
        func update(_ c: PersonViewController) {
            switch self {
            case .add:
                c.navigationItem.title = NSLocalizedString("add-person", comment: "")
            case .edit:
                c.navigationItem.title = NSLocalizedString("edit-person", comment: "")
                c.firstNameTextField.text = c.person?.firstName
                c.lastNameTextField.text = c.person?.lastName
            }
        }
    }
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!

    let editingContext = DataStore.store.editingContext
    var person: Person?
    private var viewState: ViewState = .edit

    override func viewDidLoad() {
        super.viewDidLoad()

        firstNameTextField.placeholder = NSLocalizedString("person.edit.first-name-placeholder", comment: "")
        lastNameTextField.placeholder = NSLocalizedString("person.edit.last-name-placeholder", comment: "")

        if let person = Person.defaultPerson(editingContext) {
            self.person = person
            viewState = .edit
        } else {
            self.person = Person(context: editingContext)
            viewState = .add
        }
        viewState.update(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstNameTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let person = self.person else {
            preconditionFailure("No person")
        }

        if let firstName = firstNameTextField.text {
            if let lastName = lastNameTextField.text {
                if !firstName.isEmpty && !lastName.isEmpty {
                    person.firstName = firstName
                    person.lastName = lastName
                    DataStore.store.save(editing: editingContext)
                }
            }
        }
    }
}
