//
//  DGSKDrawContextStylingProviderFactory.m
//  SpiralKit by Digital Generalists
//
//  Created by Mark Johnson on 7/29/13.
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

#import "DGSKDrawContextStylingProviderFactory.h"

#import "SpiralKitTypes.h"

#import "DGSKDrawContextStylingProviderProtocol.h"

#import "DGSKRGBDrawContextStylingProvider.h"

#import "DGSKVariableWidthDrawEffectsEngine.h"
#import "DGSKHighlighterDrawEffectsEngine.h"
#import "DGSKEraserDrawEffectsEngine.h"

@implementation DGSKDrawContextStylingProviderFactory

+ (id<DGSKDrawContextStylingProviderProtocol>) createInstanceForDrawToolType:(DGSKDrawToolType)type
{
    id<DGSKDrawContextStylingProviderProtocol> provider = nil;
    
    switch (type)
    {
        case DGSKDrawToolTypeNormal:
            provider = [[DGSKRGBDrawContextStylingProvider alloc] initAsToolType:type withEffectsEngine:[[DGSKVariableWidthDrawEffectsEngine alloc] init]];
            break;
        case DGSKDrawToolTypeHighlighter:
            provider = [[DGSKRGBDrawContextStylingProvider alloc] initAsToolType:type withEffectsEngine:[[DGSKHighlighterDrawEffectsEngine alloc] init]];
            break;
        case DGSKDrawToolTypeEraser:
            provider = [[DGSKRGBDrawContextStylingProvider alloc] initAsToolType:type withEffectsEngine:[[DGSKEraserDrawEffectsEngine alloc] init]];
            break;
        default:
            provider = nil;
            break;
    }
    
    return provider;
}

+ (id<DGSKDrawContextStylingProviderProtocol>) createInstanceWithStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)provider
{
    assert(provider != nil);
    
    return [DGSKDrawContextStylingProviderFactory createInstanceForDrawToolType:provider.drawToolType withStylingProvider:provider];
}

+ (id<DGSKDrawContextStylingProviderProtocol>) createInstanceForDrawToolType:(DGSKDrawToolType)type withStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)provider
{
    assert(provider != nil);
    
    id<DGSKDrawContextStylingProviderProtocol> newProvider = nil;
    
    switch (type)
    {
        case DGSKDrawToolTypeNormal:
            newProvider = [[DGSKRGBDrawContextStylingProvider alloc] initWithStylingProvider:provider];
            newProvider.effectsEngine = [[DGSKVariableWidthDrawEffectsEngine alloc] init];
            break;
        case DGSKDrawToolTypeHighlighter:
            newProvider = [[DGSKRGBDrawContextStylingProvider alloc] initWithStylingProvider:provider];
            newProvider.effectsEngine = [[DGSKHighlighterDrawEffectsEngine alloc] init];
            break;
        case DGSKDrawToolTypeEraser:
            newProvider = [[DGSKRGBDrawContextStylingProvider alloc] initWithStylingProvider:provider];
            newProvider.effectsEngine = [[DGSKEraserDrawEffectsEngine alloc] init];
            break;
        default:
            newProvider = nil;
            break;
    }

    if (newProvider)
    {
        [newProvider applyToolType:type];
    }

    return newProvider;
}

@end
