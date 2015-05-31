//
//  DGSKHighlighterDrawEffectsEngine.m
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

#import "DGSKHighlighterDrawEffectsEngine.h"

#import "DGSKDrawContextStylingProviderProtocol.h"

#import "DGSKRGBDrawContextStylingProvider.h"

#define DRAW_CONTEXT_STYLE_HIGHLIGHTER_COLOR_ALPHA 1.0
#define DRAW_CONTEXT_STYLE_HIGHLIGHTER_ALPHA_PERCENTAGE 0.3
#define DRAW_CONTEXT_STYLE_HIGHLIGHTER_BLEND_MODE kCGBlendModeExclusion/*kCGBlendModeOverlay*/

#define ENCODING_PROPERTY_ORIGINAL_COLOR_ALPHA @"originalColorComponentAlpha"

@interface DGSKHighlighterDrawEffectsEngine()

@property (nonatomic) CGFloat originalColorComponentAlpha;
@property (nonatomic) CGFloat appliedColorComponentAlpha;

@end

@implementation DGSKHighlighterDrawEffectsEngine

@synthesize originalColorComponentAlpha = _originalColorComponentAlpha;
@synthesize appliedColorComponentAlpha = _appliedColorComponentAlpha;

- (id) init
{
    self = [super init];
    if (self)
    {
        self.appliedBlendMode = DRAW_CONTEXT_STYLE_HIGHLIGHTER_BLEND_MODE;
        self.originalColorComponentAlpha = DRAW_CONTEXT_STYLE_HIGHLIGHTER_COLOR_ALPHA;
        self.appliedColorComponentAlpha = DRAW_CONTEXT_STYLE_HIGHLIGHTER_ALPHA_PERCENTAGE;
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeFloat:self.originalColorComponentAlpha forKey:ENCODING_PROPERTY_ORIGINAL_COLOR_ALPHA];
}

- (id) initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self)
    {
        _originalColorComponentAlpha = [decoder decodeFloatForKey:ENCODING_PROPERTY_ORIGINAL_COLOR_ALPHA];
        self.appliedBlendMode = DRAW_CONTEXT_STYLE_HIGHLIGHTER_BLEND_MODE;
        self.appliedColorComponentAlpha = DRAW_CONTEXT_STYLE_HIGHLIGHTER_ALPHA_PERCENTAGE;
    }
    return self;
}

- (void) calibrateToStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider
{
    [super calibrateToStylingProvider:stylingProvider];
    
    if ([stylingProvider isKindOfClass:[DGSKRGBDrawContextStylingProvider class]])
    {
        DGSKRGBDrawContextStylingProvider *typedStylingProvider = (DGSKRGBDrawContextStylingProvider *)stylingProvider;
        self.originalColorComponentAlpha = typedStylingProvider.colorComponentAlpha;
    }
}

- (void) applyEffectsBasedOnPoints:(NSArray *)points toStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider
{
    [super applyEffectsBasedOnPoints:points toStylingProvider:stylingProvider];
    
    if ([stylingProvider isKindOfClass:[DGSKRGBDrawContextStylingProvider class]])
    {
        DGSKRGBDrawContextStylingProvider *typedStylingProvider = (DGSKRGBDrawContextStylingProvider *)stylingProvider;
        typedStylingProvider.colorComponentAlpha = self.appliedColorComponentAlpha;
    }
}

- (void) resetEffectsForStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider
{
    [super resetEffectsForStylingProvider:stylingProvider];
    
    if ([stylingProvider isKindOfClass:[DGSKRGBDrawContextStylingProvider class]])
    {
        DGSKRGBDrawContextStylingProvider *typedStylingProvider = (DGSKRGBDrawContextStylingProvider *)stylingProvider;
        typedStylingProvider.colorComponentAlpha = self.originalColorComponentAlpha;
    }
}

@end
