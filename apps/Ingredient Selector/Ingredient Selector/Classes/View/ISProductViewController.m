//
//  ISProductViewController.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/25/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISProductViewController.h"
#import "ISProduct.h"


@interface ISProductViewController ()
@property (strong, nonatomic) IBOutlet UILabel *productNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *productDetailLabel;
@end


@implementation ISProductViewController

- (void) viewWillAppear: (BOOL) animated {
    [super viewWillAppear: animated];
    self.title = _product.name;
    _productNameLabel.text = _product.name;
    _productDetailLabel.text = _product.detail;
}

@end
