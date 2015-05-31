//
//  ViewController.m
//  SpiralKitReference
//
//  Created by Mark Johnson on 4/24/15.
//  Copyright (c) 2015 Digital Generalists, LLC.
//
/*
 * Copyright 2015 Digital Generalists, LLC.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#import "ViewController.h"
#import <UIKit/UIKit.h>

#import "DrawData.h"

@interface ViewController ()

@property (nonatomic, strong) DrawData<DGSKDrawDataProviderProtocol>* drawData;

@property (nonatomic, strong) UIView<DGSKDrawViewProtocol> *drawView;

@property (strong, nonatomic) IBOutlet UISegmentedControl *drawToolSelector;
@property (strong, nonatomic) IBOutlet UISegmentedControl *colorSelector;
@property (strong, nonatomic) IBOutlet UISegmentedControl *strokeSizeSelector;

- (IBAction) drawToolSelected:(id)sender;
- (IBAction) colorSelected:(id)sender;
- (IBAction) sizeSelected:(id)sender;

@end

@implementation ViewController

@synthesize drawView = _drawView;
@synthesize drawData = _drawData;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.drawData = [[DrawData alloc] init];
    // This can be substituted with any DGSKDrawViewProtool-compliant implementation of UIView.
    self.drawView = [[DGSKDrawView alloc] initWithFrame:self.view.frame];
    
    // This can be substituted with any DGSKDrawContextStylingProviderProtocol-compliant implementation.
    id<DGSKDrawContextStylingProviderProtocol> stylingProvider = [DGSKDrawContextStylingProviderFactory createInstanceForDrawToolType:DGSKDrawToolTypeNormal];
    stylingProvider.color = [UIColor blackColor];
    stylingProvider.lineWidth = 2;
    [stylingProvider.effectsEngine calibrateToStylingProvider:stylingProvider];

    // Returns the created draw engine instance if you want to track it.
    [DGSKDrawEngineFactory createInstanceForDrawView:self.drawView withStylingProvider:stylingProvider data:self.drawData];
    
    [self.view insertSubview:self.drawView atIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (IBAction) drawToolSelected:(id)sender
{
    id<DGSKDrawContextStylingProviderProtocol> stylingProvider;

    switch (self.drawToolSelector.selectedSegmentIndex) {
        case DGSKDrawToolTypeHighlighter:
            stylingProvider = [DGSKDrawContextStylingProviderFactory createInstanceForDrawToolType:DGSKDrawToolTypeHighlighter];
            stylingProvider.color = [[self.self.drawView.drawEngine stylingProvider] color];
            stylingProvider.lineWidth = [self determineAppropriateLineWidth];
            [stylingProvider.effectsEngine calibrateToStylingProvider:stylingProvider];
            [self.colorSelector setEnabled:true];
            break;
        case DGSKDrawToolTypeEraser:
            stylingProvider = [DGSKDrawContextStylingProviderFactory createInstanceForDrawToolType:DGSKDrawToolTypeEraser];
            stylingProvider.color = [[self.self.drawView.drawEngine stylingProvider] color];
            stylingProvider.lineWidth = [self determineAppropriateLineWidth];
            [stylingProvider.effectsEngine calibrateToStylingProvider:stylingProvider];
            [self.colorSelector setEnabled:false];
            break;
        case DGSKDrawToolTypeNormal:
        default:
            stylingProvider = [DGSKDrawContextStylingProviderFactory createInstanceForDrawToolType:DGSKDrawToolTypeNormal];
            stylingProvider.color = [[self.self.drawView.drawEngine stylingProvider] color];
            stylingProvider.lineWidth = [self determineAppropriateLineWidth];
            [stylingProvider.effectsEngine calibrateToStylingProvider:stylingProvider];
            [self.colorSelector setEnabled:true];
            break;
    }
    
    // Returns the created draw engine instance if you want to track it.
    [DGSKDrawEngineFactory createInstanceForDrawView:self.drawView withStylingProvider:stylingProvider data:self.drawData];
}

- (IBAction) colorSelected:(id)sender
{
    id<DGSKDrawContextStylingProviderProtocol> stylingProvider = [DGSKDrawContextStylingProviderFactory createInstanceWithStylingProvider:[self.self.drawView.drawEngine stylingProvider]];
    
    switch (self.colorSelector.selectedSegmentIndex) {
        case 1:
            stylingProvider.color = [UIColor redColor];
            break;
        case 0:
        default:
            stylingProvider.color = [UIColor blackColor];
            break;
    }
    
    // Returns the created draw engine instance if you want to track it.
    [DGSKDrawEngineFactory createInstanceForDrawView:self.drawView withStylingProvider:stylingProvider data:self.drawData];
}

- (IBAction) sizeSelected:(id)sender
{
    id<DGSKDrawContextStylingProviderProtocol> stylingProvider = [DGSKDrawContextStylingProviderFactory createInstanceWithStylingProvider:[self.self.drawView.drawEngine stylingProvider]];
    
    stylingProvider.lineWidth = [self determineAppropriateLineWidth];
    [stylingProvider.effectsEngine calibrateToStylingProvider:stylingProvider];
    
    // Returns the created draw engine instance if you want to track it.
    [DGSKDrawEngineFactory createInstanceForDrawView:self.drawView withStylingProvider:stylingProvider data:self.drawData];
}

- (CGFloat) determineAppropriateLineWidth
{
    CGFloat lineWidth = 0;
    
    switch (self.strokeSizeSelector.selectedSegmentIndex) {
        case 1:
            lineWidth = 20;
            break;
        case 0:
        default:
            lineWidth = 2;
            break;
    }
    return lineWidth;
}

@end
