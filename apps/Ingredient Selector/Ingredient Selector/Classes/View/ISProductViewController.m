//
//  ISProductViewController.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/25/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISProductViewController.h"
#import "ISConfectionery.h"


@interface ISProductViewController ()
@property (strong, nonatomic) IBOutlet UILabel *productNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *productDetailLabel;
@property (strong, nonatomic) IBOutlet UILabel *productNotesTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *productNotesLabel;
@property (strong, nonatomic) IBOutlet UILabel *selectionCriteriaTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *selectionCriteriaLabel;
@property (strong, nonatomic) IBOutlet UILabel *suggestedUsageLevelInFormulationsTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *suggestedUsageLevelInFormulationsLabel;
@property (strong, nonatomic) IBOutlet UILabel *recommendedMaxUsageTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *recommendedMaxUsageLabel;
@property (strong, nonatomic) IBOutlet UILabel *labelDeclarationTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *labelDeclarationLabel;
@property (strong, nonatomic) IBOutlet UIStackView *mainStack;
@property (strong, nonatomic) IBOutlet UIStackView *productNotesStack;
@property (strong, nonatomic) IBOutlet UIStackView *selectionCriteriaStack;
@property (strong, nonatomic) IBOutlet UIStackView *suggestedUsageLevelInFormulationsStack;
@property (strong, nonatomic) IBOutlet UIStackView *recommendedMaxUsageStack;
@property (strong, nonatomic) IBOutlet UIStackView *labelDeclarationStack;
@end


@implementation ISProductViewController

- (void) viewWillAppear: (BOOL) animated {
    [super viewWillAppear: animated];
    self.title = _product.name;

    // Title labels
    _productNotesTitleLabel.text = NSLocalizedString(@"product.notes", nil);
    _selectionCriteriaTitleLabel.text = NSLocalizedString(@"product.confectionery.selection-criteria", nil);
    _suggestedUsageLevelInFormulationsTitleLabel.text = NSLocalizedString(@"product.confectionery.suggested-usage-level-in-formulations", nil);
    _recommendedMaxUsageLabel.text = NSLocalizedString(@"product.confectionery.recommended-max-usage", nil);
    _labelDeclarationTitleLabel.text = NSLocalizedString(@"product.confectionery.label-declaration", nil);

    _productNameLabel.text = _product.name;
    _productDetailLabel.text = _product.detail;
    _productNotesLabel.text = _product.notes;
    ISConfectionery *c = (ISConfectionery *) _product;
    _selectionCriteriaLabel.text = c.selectionCriteria;
    _suggestedUsageLevelInFormulationsLabel.text = c.suggestedUsageLevelInFormulations;
    _recommendedMaxUsageLabel.text = c.recommendedMaxUsage;
    _labelDeclarationLabel.text = c.labelDeclaration;

    if (_product.notes.length == 0) {
        [_mainStack removeArrangedSubview: _productNotesStack];
    }
    if (c.selectionCriteria.length == 0) {
        [_mainStack removeArrangedSubview: _selectionCriteriaStack];
    }
    if (c.suggestedUsageLevelInFormulations.length == 0) {
        [_mainStack removeArrangedSubview: _suggestedUsageLevelInFormulationsStack];
    }
    if (c.recommendedMaxUsage.length == 0) {
        [_mainStack removeArrangedSubview: _recommendedMaxUsageStack];
    }
    if (c.labelDeclaration.length == 0) {
        [_mainStack removeArrangedSubview: _labelDeclarationStack];
    }
}

@end
