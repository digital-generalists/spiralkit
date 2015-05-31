//
//  DGSKDrawEngineAbstract.m
//  SpiralKit by Digital Generalists
//
//  Created by Mark Johnson on 7/17/12.
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

#import "DGSKDrawEngineAbstract.h"

#import "DGSKDrawContextStylingProviderProtocol.h"

#import "DGSKRGBDrawContextStylingProvider.h"

#import "DGSKDrawDataProviderProtocol.h"

#define DEFAULT_REFRESH_RATE 1

@interface DGSKDrawEngineAbstract()

- (id) init;

@end


@implementation DGSKDrawEngineAbstract

@synthesize hostView = _hostView;

@synthesize stylingProvider = _stylingProvider;

@synthesize drawData = _drawData;

@synthesize processedTouchesForActiveStroke = _processedTouchesForActiveStroke;

@synthesize refreshRate = _refreshRate;

- (id) init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not a valid initializer for DGSKDrawEngineAbstract class instances"
                                 userInfo:nil];
    return nil;
}

- (id) initWithView:(UIView<DGSKDrawViewProtocol> *)hostView stylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider data:(id<DGSKDrawDataProviderProtocol>)drawData
{
    self = [super init];
    if (self)
    {
        self.refreshRate = DEFAULT_REFRESH_RATE;
        self.processedTouchesForActiveStroke = 0;
        
        _hostView = hostView;
        
        if (!stylingProvider)
        {
            stylingProvider = [[DGSKRGBDrawContextStylingProvider alloc] init];
        }
        
        _stylingProvider = stylingProvider;
        
        _drawData = drawData;
    }
    return self;
}

- (void) changeStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider
{
    if (!stylingProvider)
    {
        stylingProvider = [[DGSKRGBDrawContextStylingProvider alloc] init];
    }
    
    _stylingProvider = stylingProvider;
}

- (void) prepareForUnload
{
    _stylingProvider = nil;
    _drawData = nil;
    _hostView = nil;
}

@end
