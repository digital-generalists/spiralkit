//
//  DGSKBlendDrawEffectsEngineAbstract.m
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

#import "DGSKBlendDrawEffectsEngineAbstract.h"

#import "DGSKDrawContextStylingProviderProtocol.h"
#import "DGSKDrawEffectsEngineProtocol.h"

#define DRAW_CONTEXT_STYLE_DEFAULT_EFFECT_BLEND_MODE kCGBlendModeNormal

#define ENCODING_PROPERTY_ORIGINAL_BLEND_MODE @"originalBlendMode"

@interface DGSKBlendDrawEffectsEngineAbstract()

@property (nonatomic) CGBlendMode originalBlendMode;

@end

@implementation DGSKBlendDrawEffectsEngineAbstract

@synthesize appliedBlendMode = _appliedBlendMode;
@synthesize originalBlendMode = _originalBlendMode;

- (id) init
{
    self = [super init];
    if (self)
    {
        self.appliedBlendMode = DRAW_CONTEXT_STYLE_DEFAULT_EFFECT_BLEND_MODE;
        self.originalBlendMode = DRAW_CONTEXT_STYLE_DEFAULT_EFFECT_BLEND_MODE;
    }
    return self;
}

- (id) initWithEffectsEngine:(id<DGSKDrawEffectsEngineProtocol>)effectsEngine
{
    self = [self init];
    if (self)
    {
        if ([effectsEngine isKindOfClass:[DGSKBlendDrawEffectsEngineAbstract class]])
        {
            DGSKBlendDrawEffectsEngineAbstract *typedEffectsEngine = effectsEngine;
            self.appliedBlendMode = typedEffectsEngine.appliedBlendMode;
            self.originalBlendMode = typedEffectsEngine.originalBlendMode;
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeInteger:self.originalBlendMode forKey:ENCODING_PROPERTY_ORIGINAL_BLEND_MODE];
}

- (id) initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self)
    {
        _originalBlendMode = (CGBlendMode)[decoder decodeIntegerForKey:ENCODING_PROPERTY_ORIGINAL_BLEND_MODE];
        _appliedBlendMode = self.originalBlendMode;
    }
    return self;
}

- (void) calibrateToStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider
{
    self.originalBlendMode = stylingProvider.blendMode;
}

- (void) applyEffectsBasedOnPoints:(NSArray *)points toStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider
{
    if (!stylingProvider)
    {
        return;
    }
    
    stylingProvider.blendMode = self.appliedBlendMode;
}

- (void) resetEffectsForStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider
{
    stylingProvider.blendMode = self.originalBlendMode;
}

@end
