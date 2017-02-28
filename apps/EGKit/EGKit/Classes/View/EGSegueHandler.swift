//
//  EGSegueHandler.swift
//  EGKit
//
//  Created by Alex Romayev on 2/27/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import UIKit

public protocol EGSegueHandlerType {
    associatedtype EGSegueIdentifier: RawRepresentable
}

public extension EGSegueHandlerType where Self: UIViewController, EGSegueIdentifier.RawValue == String {
    func performSegue(withIdentifier identifier: EGSegueIdentifier, sender: Any?) {
        performSegue(withIdentifier: identifier.rawValue, sender: sender)
    }

    func EGSegueIdentifier(forSegue segue: UIStoryboardSegue) -> EGSegueIdentifier {
        guard let identifier = segue.identifier, let EGSegueIdentifier = EGSegueIdentifier(rawValue: identifier) else {
            fatalError("Couldn't handle segue identifier \(segue.identifier) for view controller of type \(type(of: self)).")
        }
        return EGSegueIdentifier
    }
}

