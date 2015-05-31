//
//  DGSKVariableWidthDrawEffectsEngine.m
//  SpiralKit by Digital Generalists
//
//  Created by Mark Johnson on 8/21/12.
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

#import "DGSKVariableWidthDrawEffectsEngine.h"

#import "DGSKDrawContextStylingProviderProtocol.h"
#import "DGSKDrawEffectsEngineProtocol.h"

#import "DGSKDrawUtils.h"

#define PHYSICS_DEFAULT_MINIMUM_LINE_WIDTH_PERCENTAGE 0.4
#define PHYSICS_DEFAULT_LINE_WIDTH_ADJUSTMENT_AMOUNT 0.05
#define PHYSICS_DEFAULT_LINE_POINT_DISTANCE_SCREEN_DISTANCE_THRESHOLD_PERCENTAGE 0.15
#define DRAW_CONTEXT_STYLE_PEN_BLEND_MODE kCGBlendModeNormal

#define ENCODING_PROPERTY_ORIGINAL_LINE_WIDTH @"originalLineWidth"

@interface DGSKVariableWidthDrawEffectsEngine()

@property (nonatomic) CGFloat appliedLineWidth;
@property (nonatomic) CGFloat originalLineWidth;

- (void) applyAccelerationToStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider;
- (void) applyDeccelerationToStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider;

@end


@implementation DGSKVariableWidthDrawEffectsEngine

@synthesize appliedLineWidth = _appliedLineWidth;
@synthesize originalLineWidth = _originalLineWidth;

- (id) init
{
    self = [super init];
    if (self)
    {
        self.appliedLineWidth = 0;
        self.originalLineWidth = 0;
    }
    return self;
}

- (id) initWithEffectsEngine:(id<DGSKDrawEffectsEngineProtocol>)effectsEngine
{
    self = [super init];
    if (self)
    {
        if ([effectsEngine isKindOfClass:[DGSKVariableWidthDrawEffectsEngine class]])
        {
            DGSKVariableWidthDrawEffectsEngine *typedEffectsEngine = effectsEngine;
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
        _appliedLineWidth = self.originalLineWidth;
    }
    return self;
}

- (void) calibrateToStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider
{
    stylingProvider.blendMode = DRAW_CONTEXT_STYLE_PEN_BLEND_MODE;
    self.originalLineWidth = stylingProvider.lineWidth;
    self.appliedLineWidth = stylingProvider.lineWidth;
}

- (void) applyEffectsBasedOnPoints:(NSArray *)points toStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider
{
    if ([points count] == 0)
    {
        return;
    }
    
    if (!stylingProvider)
    {
        return;
    }
    
    CGPoint point1;
    CGPoint point2;
    
    point1 = [[points objectAtIndex:0] CGPointValue];
    point2 = [[points objectAtIndex:([points count]-1)] CGPointValue];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if ([DGSKDrawUtils distanceBetweenPoint1:point1 point2:point2] > (screenBounds.size.width * PHYSICS_DEFAULT_LINE_POINT_DISTANCE_SCREEN_DISTANCE_THRESHOLD_PERCENTAGE))
    {
        [self applyAccelerationToStylingProvider:stylingProvider];
    }
    else
    {
        [self applyDeccelerationToStylingProvider:stylingProvider];
    }
}

- (void) applyAccelerationToStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider
{
    if (self.appliedLineWidth > (self.originalLineWidth * PHYSICS_DEFAULT_MINIMUM_LINE_WIDTH_PERCENTAGE))
    {
        self.appliedLineWidth = self.appliedLineWidth - (self.appliedLineWidth*PHYSICS_DEFAULT_LINE_WIDTH_ADJUSTMENT_AMOUNT);
        
        if (self.appliedLineWidth < (self.originalLineWidth * PHYSICS_DEFAULT_MINIMUM_LINE_WIDTH_PERCENTAGE))
        {
            self.appliedLineWidth = self.originalLineWidth * PHYSICS_DEFAULT_MINIMUM_LINE_WIDTH_PERCENTAGE;
        }
    }
    
    stylingProvider.lineWidth = self.appliedLineWidth;
}

- (void) applyDeccelerationToStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider
{
    if (self.appliedLineWidth < self.originalLineWidth)
    {
        self.appliedLineWidth = self.appliedLineWidth + (self.appliedLineWidth*PHYSICS_DEFAULT_LINE_WIDTH_ADJUSTMENT_AMOUNT);
        
        if (self.appliedLineWidth > self.originalLineWidth)
        {
            self.appliedLineWidth = self.originalLineWidth;
        }
    }
    
    stylingProvider.lineWidth = self.appliedLineWidth;
}

- (void) resetEffectsForStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider
{
    stylingProvider.blendMode = DRAW_CONTEXT_STYLE_PEN_BLEND_MODE;

    if (self.originalLineWidth <= 0)
    {
        return;
    }
    
    self.appliedLineWidth = self.originalLineWidth;
    
    stylingProvider.lineWidth = self.appliedLineWidth;
}

@end
