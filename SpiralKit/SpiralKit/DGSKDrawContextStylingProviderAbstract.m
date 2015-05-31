//
//  DGSKDrawContextStylingProvider.m
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

#import "DGSKDrawContextStylingProviderAbstract.h"

#import "SpiralKitTypes.h"

#import "DGSKDrawContextStylingProviderProtocol.h"
#import "DGSKDrawEffectsEngineProtocol.h"

#import "DGSKGraphicsUtils.h"

#define DRAW_CONTEXT_STYLE_DEFAULT_BLEND_MODE kCGBlendModeNormal
#define DRAW_CONTEXT_STYLE_DEFAULT_LINE_STYLE kCGLineCapRound
#define DRAW_CONTEXT_STYLE_DEFAULT_LINE_WIDTH 5.0
#define DRAW_CONTEXT_STYLE_DEFAULT_HIGHLIGHTER_LINE_WIDTH 13.0
#define DRAW_CONTEXT_STYLE_DEFAULT_ERASER_LINE_WIDTH 21.0

#define ENCODING_PROPERTY_TOOL_TYPE @"drawToolType"
#define ENCODING_PROPERTY_BLEND_MODE @"blendMode"
#define ENCODING_PROPERTY_LINE_STYLE @"lineStyle"
#define ENCODING_PROPERTY_LINE_WIDTH @"lineWidth"
#define ENCODING_PROPERTY_EFFECTS_ENGINE @"effectsEngine"


@interface DGSKDrawContextStylingProviderAbstract()

@end

@implementation DGSKDrawContextStylingProviderAbstract

@synthesize drawToolType = _drawToolType;

@synthesize effectsEngine = _effectsEngine;

@synthesize blendMode = _blendMode;

@synthesize lineStyle = _lineStyle;
@synthesize lineWidth = _lineWidth;

- (id) init
{
    self = [super init];
    if (self)
    {
        [self applyToolType:DGSKDrawToolTypeNormal];
        
        self.blendMode = DRAW_CONTEXT_STYLE_DEFAULT_BLEND_MODE;
        
        self.lineStyle = DRAW_CONTEXT_STYLE_DEFAULT_LINE_STYLE;
        self.lineWidth = DRAW_CONTEXT_STYLE_DEFAULT_LINE_WIDTH;
    }
    return self;
}

- (id) initAsToolType:(DGSKDrawToolType)type
{
    self = [self init];
    if (self)
    {
        [self applyToolType:type];
        
        switch (self.drawToolType)
        {
            case DGSKDrawToolTypeNormal:
                // The default, parameterless init call sets these up properly.
                // Setting the value here would be harmless but redundant, so
                // not placing here to save a few minimal processor cycles.
                break;
            case DGSKDrawToolTypeHighlighter:
                self.lineWidth = DRAW_CONTEXT_STYLE_DEFAULT_HIGHLIGHTER_LINE_WIDTH;
                break;
            case DGSKDrawToolTypeEraser:
                self.lineWidth = DRAW_CONTEXT_STYLE_DEFAULT_ERASER_LINE_WIDTH;
                break;
            default:
                break;
        }
        
    }
    return self;
}

- (id) initWithStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)provider
{
    self = [self init];
    if (self)
    {
        [self applyToolType:provider.drawToolType];
        
        self.blendMode = provider.blendMode;
        
        self.lineStyle = provider.lineStyle;
        self.lineWidth = provider.lineWidth;
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:self.drawToolType forKey:ENCODING_PROPERTY_TOOL_TYPE];
    [coder encodeInteger:self.blendMode forKey:ENCODING_PROPERTY_BLEND_MODE];
    [coder encodeInteger:self.lineStyle forKey:ENCODING_PROPERTY_LINE_STYLE];
    [coder encodeFloat:self.lineWidth forKey:ENCODING_PROPERTY_LINE_WIDTH];
    [coder encodeObject:self.effectsEngine forKey:ENCODING_PROPERTY_EFFECTS_ENGINE];
}

- (id) initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self)
    {
        _drawToolType = (DGSKDrawToolType)[decoder decodeIntegerForKey:ENCODING_PROPERTY_TOOL_TYPE];
        _blendMode = (CGBlendMode)[decoder decodeIntegerForKey:ENCODING_PROPERTY_BLEND_MODE];
        _lineStyle = (CGLineCap)[decoder decodeIntegerForKey:ENCODING_PROPERTY_LINE_STYLE];
        _lineWidth = [decoder decodeFloatForKey:ENCODING_PROPERTY_LINE_WIDTH];
        _effectsEngine = [decoder decodeObjectForKey:ENCODING_PROPERTY_EFFECTS_ENGINE];
    }
    return self;
}

- (void) setEffectsEngine:(id<DGSKDrawEffectsEngineProtocol>)effectsEngine
{
    _effectsEngine = effectsEngine;
    
    if ([self conformsToProtocol:@protocol(DGSKDrawContextStylingProviderProtocol)])
    {
        id<DGSKDrawContextStylingProviderProtocol> typedProvider = (id<DGSKDrawContextStylingProviderProtocol>)self;
        [self.effectsEngine calibrateToStylingProvider:typedProvider];
    }
}

- (bool) applyPropertiesToContext:(CGContextRef)context
{
    CGContextSetBlendMode(context, self.blendMode);
    CGContextSetLineCap(context, self.lineStyle);
    CGFloat lineWidthToApply = self.lineWidth;
    CGContextSetLineWidth(context, lineWidthToApply);

    return true;
}

- (bool) applyPropertiesToContext:(CGContextRef)context withEffectsBasedOnPoints:(NSArray *)points
{
    if ([self conformsToProtocol:@protocol(DGSKDrawContextStylingProviderProtocol)])
    {
        id<DGSKDrawContextStylingProviderProtocol> typedProvider = (id<DGSKDrawContextStylingProviderProtocol>)self;
        [self.effectsEngine applyEffectsBasedOnPoints:points toStylingProvider:typedProvider];
    }
    
    return [self applyPropertiesToContext:context];
}

- (UIColor *) color
{
    // These are fallback defaults.  Concrete classes will override this.
    return [self applyStyleToProvidedColor:[UIColor blackColor]];
}

- (void) setColor:(UIColor *)color
{
    // These are fallback defaults.  Concrete classes will override this.
    // Default color remains black.
}

- (void) resetEffects
{
    if ([self conformsToProtocol:@protocol(DGSKDrawContextStylingProviderProtocol)])
    {
        id<DGSKDrawContextStylingProviderProtocol> typedProvider = (id<DGSKDrawContextStylingProviderProtocol>)self;
        [self.effectsEngine resetEffectsForStylingProvider:typedProvider];
    }
}

- (void) applyToolType:(DGSKDrawToolType)toolType
{
    self.drawToolType = toolType;
}

- (UIColor *) applyStyleToProvidedColor:(UIColor *)color
{
    // These are fallback defaults.  Concrete classes will override this.
    return color;
}

@end
