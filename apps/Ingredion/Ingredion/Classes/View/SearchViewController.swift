//
//  SearchViewController.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/13/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

protocol SearchViewControllerDelegate: class {
    var productType: Product.ProductType { get }
}

class SearchViewController : ViewController {
    weak var delegate: SearchViewControllerDelegate?
}
