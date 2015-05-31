//
//  DGSKEraserDrawEffectsEngine.m
//  SpiralKit by Digital Generalists
//
//  Created by Mark Johnson on 2/17/13.
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

#import "DGSKEraserDrawEffectsEngine.h"

#import "DGSKDrawContextStylingProviderProtocol.h"

#define DRAW_CONTEXT_STYLE_ERASER_LINE_WIDTH_MULTIPLIER 3.875
#define DRAW_CONTEXT_STYLE_ERASER_BLEND_MODE kCGBlendModeClear

#define ENCODING_PROPERTY_ORIGINAL_LINE_WIDTH @"originalLineWidth"

@interface DGSKEraserDrawEffectsEngine()

@property (nonatomic) CGFloat appliedLineWidth;
@property (nonatomic) CGFloat originalLineWidth;

@end

@implementation DGSKEraserDrawEffectsEngine

@synthesize appliedLineWidth = _appliedLineWidth;
@synthesize originalLineWidth = _originalLineWidth;

- (id) init
{
    self = [super init];
    if (self)
    {
        self.appliedLineWidth = 0;
        self.originalLineWidth = 0;
        self.appliedBlendMode = DRAW_CONTEXT_STYLE_ERASER_BLEND_MODE;
    }
    return self;
}

- (id) initWithEffectsEngine:(id<DGSKDrawEffectsEngineProtocol>)effectsEngine
{
    // NOTE:  This initializer is a consequence of the odd inheritance hierarchy
    // between the abstract base classes and the relationship between the effects
    // engine and the styling provider.  The model relationship between those
    // objects likely should be reviewed.
    self.appliedLineWidth = 0;
    self.originalLineWidth = 0;
    self.appliedBlendMode = DRAW_CONTEXT_STYLE_ERASER_BLEND_MODE;
    
    self = [super initWithEffectsEngine:effectsEngine];
    if (self)
    {
        if ([effectsEngine isKindOfClass:[DGSKEraserDrawEffectsEngine class]])
        {
            DGSKEraserDrawEffectsEngine *typedEffectsEngine = effectsEngine;
            self.appliedBlendMode = typedEffectsEngine.appliedBlendMode;
            self.appliedLineWidth = typedEffectsEngine.appliedLineWidth;
            self.originalLineWidth = typedEffectsEngine.originalLineWidth;
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeFloat:self.originalLineWidth forKey:ENCODING_PROPERTY_ORIGINAL_LINE_WIDTH];
}

- (id) initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self)
    {
        _originalLineWidth = [decoder decodeFloatForKey:ENCODING_PROPERTY_ORIGINAL_LINE_WIDTH];
        _appliedLineWidth = _originalLineWidth * DRAW_CONTEXT_STYLE_ERASER_LINE_WIDTH_MULTIPLIER;
        self.appliedBlendMode = DRAW_CONTEXT_STYLE_ERASER_BLEND_MODE;
    }
    return self;
}

- (void) calibrateToStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider
{
    [super calibrateToStylingProvider:stylingProvider];
    
    self.originalLineWidth = stylingProvider.lineWidth;
    self.appliedLineWidth = stylingProvider.lineWidth * DRAW_CONTEXT_STYLE_ERASER_LINE_WIDTH_MULTIPLIER;
}

- (void) applyEffectsBasedOnPoints:(NSArray *)points toStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider
{
    [super applyEffectsBasedOnPoints:points toStylingProvider:stylingProvider];
    
    stylingProvider.lineWidth = self.appliedLineWidth;
}

- (void) resetEffectsForStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider
{
    [super resetEffectsForStylingProvider:stylingProvider];
    
    if (self.originalLineWidth <= 0)
    {
        return;
    }
    
    stylingProvider.lineWidth = self.originalLineWidth;
}

@end
