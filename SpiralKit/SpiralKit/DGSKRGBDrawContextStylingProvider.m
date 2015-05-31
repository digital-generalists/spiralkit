//
//  DGSKRGBDrawContextStylingProvider.m
//  SpiralKit by Digital Generalists
//
//  Created by Mark Johnson on 7/21/12.
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

#import "DGSKRGBDrawContextStylingProvider.h"

#import "SpiralKitTypes.h"

#import "DGSKDrawContextStylingProviderProtocol.h"
#import "DGSKDrawEffectsEngineProtocol.h"

#import "DGSKGraphicsUtils.h"

#define DRAW_CONTEXT_STYLE_DEFAULT_COLOR_ALPHA 1.0
#define DRAW_CONTEXT_STYLE_DEFAULT_COLOR_RED 0.0
#define DRAW_CONTEXT_STYLE_DEFAULT_COLOR_GREEN 0.0
#define DRAW_CONTEXT_STYLE_DEFAULT_COLOR_BLUE 0.0

#define ENCODING_PROPERTY_COLOR_ALPHA @"colorAlpha"
#define ENCODING_PROPERTY_COLOR_RED @"colorRed"
#define ENCODING_PROPERTY_COLOR_GREEN @"colorGreen"
#define ENCODING_PROPERTY_COLOR_BLUE @"colorBlue"

@interface DGSKRGBDrawContextStylingProvider()

@end

@implementation DGSKRGBDrawContextStylingProvider

@synthesize CreateStylingColorSpace = _CreateStylingColorSpace;

@synthesize colorComponentRed = _colorComponentRed;
@synthesize colorComponentGreen = _colorComponentGreen;
@synthesize colorComponentBlue = _colorComponentBlue;
@synthesize colorComponentAlpha = _colorComponentAlpha;

- (id) init
{
    self = [super init];
    if (self)
    {
        _CreateStylingColorSpace = &CGColorSpaceCreateDeviceRGB;
        
        self.colorComponentRed = DRAW_CONTEXT_STYLE_DEFAULT_COLOR_RED;
        self.colorComponentGreen = DRAW_CONTEXT_STYLE_DEFAULT_COLOR_GREEN;
        self.colorComponentBlue = DRAW_CONTEXT_STYLE_DEFAULT_COLOR_BLUE;
        self.colorComponentAlpha = DRAW_CONTEXT_STYLE_DEFAULT_COLOR_ALPHA;
    }
    return self;
}

- (id) initWithStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)provider
{
    self = [super initWithStylingProvider:provider];
    if (self)
    {
        if ([provider isKindOfClass:[DGSKRGBDrawContextStylingProvider class]])
        {
            DGSKRGBDrawContextStylingProvider *typedProvider = (DGSKRGBDrawContextStylingProvider *)provider;
            self.colorComponentRed = typedProvider.colorComponentRed;
            self.colorComponentGreen = typedProvider.colorComponentGreen;
            self.colorComponentBlue = typedProvider.colorComponentBlue;
            self.colorComponentAlpha = typedProvider.colorComponentAlpha;
        }
        
        id<DGSKDrawEffectsEngineProtocol> effectsEngine = provider.effectsEngine;
        // The reset of effects is performed here because the
        // assigment of the effectsEngine should calibrate the
        // effects engine to the styling provider on assignment.
        [effectsEngine resetEffectsForStylingProvider:self];
        self.effectsEngine = effectsEngine;
    }
    return self;
}

- (id) initAsToolType:(DGSKDrawToolType)type
{
    self = [super initAsToolType:type];
    if (self)
    {
        _CreateStylingColorSpace = &CGColorSpaceCreateDeviceRGB;
        
        self.colorComponentRed = DRAW_CONTEXT_STYLE_DEFAULT_COLOR_RED;
        self.colorComponentGreen = DRAW_CONTEXT_STYLE_DEFAULT_COLOR_GREEN;
        self.colorComponentBlue = DRAW_CONTEXT_STYLE_DEFAULT_COLOR_BLUE;
        self.colorComponentAlpha = DRAW_CONTEXT_STYLE_DEFAULT_COLOR_ALPHA;
    }
    return self;
}

- (id) initWithEffectsEngine:(id<DGSKDrawEffectsEngineProtocol>)effectsEngine
{
    self = [self initAsToolType:DGSKDrawToolTypeNormal withEffectsEngine:effectsEngine];
    if (self)
    {
        
    }
    return self;
}

- (id) initAsToolType:(DGSKDrawToolType)type withEffectsEngine:(id<DGSKDrawEffectsEngineProtocol>)effectsEngine
{
    self = [self initAsToolType:type];
    if (self)
    {
        switch (self.drawToolType)
        {
            case DGSKDrawToolTypeNormal:
                // The default, parameterless init call sets these up properly.
                // Setting the value here would be harmless and redundant, so
                // not placing here to save a few minimal processor cycles.
                break;
            case DGSKDrawToolTypeHighlighter:
                {
                    // NOTE:  If this is changed to a monochrome color, the components will need to be mapped
                    // to accomodate that!
                    UIColor *defaultHighlighterColor = [UIColor orangeColor];
                    const CGFloat *components = CGColorGetComponents(defaultHighlighterColor.CGColor);
                    self.colorComponentRed = components[0];
                    self.colorComponentGreen = components[1];
                    self.colorComponentBlue = components[2];
                }
                break;
            case DGSKDrawToolTypeEraser:
                // The default, parameterless init call sets these up properly.
                // Setting the value here would be harmless and redundant, so
                // not placing here to save a few minimal processor cycles.
                break;
            default:
                break;
        }

        self.effectsEngine = effectsEngine;
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeFloat:self.colorComponentAlpha forKey:ENCODING_PROPERTY_COLOR_ALPHA];
    [coder encodeFloat:self.colorComponentRed forKey:ENCODING_PROPERTY_COLOR_RED];
    [coder encodeFloat:self.colorComponentGreen forKey:ENCODING_PROPERTY_COLOR_GREEN];
    [coder encodeFloat:self.colorComponentBlue forKey:ENCODING_PROPERTY_COLOR_BLUE];
}

- (id) initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self)
    {
        _colorComponentAlpha = [decoder decodeFloatForKey:ENCODING_PROPERTY_COLOR_ALPHA];
        _colorComponentRed = [decoder decodeFloatForKey:ENCODING_PROPERTY_COLOR_RED];
        _colorComponentGreen = [decoder decodeFloatForKey:ENCODING_PROPERTY_COLOR_GREEN];
        _colorComponentBlue = [decoder decodeFloatForKey:ENCODING_PROPERTY_COLOR_BLUE];
    }
    return self;
}

- (UIColor *) color
{
    UIColor *activeColor = [UIColor colorWithRed:(self.colorComponentRed) green:(self.colorComponentGreen) blue:(self.colorComponentBlue) alpha:DRAW_CONTEXT_STYLE_DEFAULT_COLOR_ALPHA];
    return [self applyStyleToProvidedColor:activeColor];
}

- (void) setColor:(UIColor *)color
{
    if (CGColorGetNumberOfComponents(color.CGColor) == 4)
    {
        const CGFloat *colorComponents = CGColorGetComponents(color.CGColor);
        //self.colorComponentAlpha = colorComponents[3]; // Highlighter manages alpha
        self.colorComponentRed = colorComponents[0];
        self.colorComponentGreen = colorComponents[1];
        self.colorComponentBlue = colorComponents[2];
    }
    // Monochromatic colors
    else if (CGColorGetNumberOfComponents(color.CGColor) == 2)
    {
        // Monochromatic colors (black-to-white with grayscale in between)
        // are represented by the same scale value across red, green, and blue.
        const CGFloat *colorComponents = CGColorGetComponents(color.CGColor);
        //self.colorComponentAlpha = colorComponents[1]; // Highlighter manages alpha
        self.colorComponentRed = colorComponents[0];
        self.colorComponentGreen = colorComponents[0];
        self.colorComponentBlue = colorComponents[0];
    }
}

- (UIColor *) applyStyleToProvidedColor:(UIColor *)color
{
    [self.effectsEngine applyEffectsBasedOnPoints:nil toStylingProvider:self];
    
    CGFloat redComponent = DRAW_CONTEXT_STYLE_DEFAULT_COLOR_RED;
    CGFloat greenComponent = DRAW_CONTEXT_STYLE_DEFAULT_COLOR_GREEN;
    CGFloat blueComponent = DRAW_CONTEXT_STYLE_DEFAULT_COLOR_BLUE;
    
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    if(CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) == kCGColorSpaceModelMonochrome)
    {
        redComponent = components[0];
        greenComponent = components[0];
        blueComponent = components[0];
    }
    else if(CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) == kCGColorSpaceModelRGB)
    {
        redComponent = components[0];
        greenComponent = components[1];
        blueComponent = components[2];
    }
    // NOTE: The eraser tool will essentially have a transparent color.  If the UI of the application intends to
    // provide a visual indicator for the eraser tool based on the color, the caller is responsible for substituting
    // the appropriate visual indicator to the application UI.
    UIColor *styledColor = [UIColor colorWithRed:(redComponent) green:(greenComponent) blue:(blueComponent) alpha:self.colorComponentAlpha];
    return styledColor;
}

- (bool) applyPropertiesToContext:(CGContextRef)context
{
    if ([super applyPropertiesToContext:context])
    {
        CGColorSpaceRef colorspace = [self CreateStylingColorSpace]();
        CGFloat components[] = {self.colorComponentRed, self.colorComponentGreen, self.colorComponentBlue, self.colorComponentAlpha};
        CGColorRef color = CGColorCreate(colorspace, components);
        CGContextSetStrokeColorWithColor(context, color);
        
        CGColorSpaceRelease(colorspace);
        CGColorRelease(color);

        return true;
    }
    else 
    {
        return false;
    }
}

- (void) applyToolType:(DGSKDrawToolType)toolType
{
    [super applyToolType:toolType];
}

@end
