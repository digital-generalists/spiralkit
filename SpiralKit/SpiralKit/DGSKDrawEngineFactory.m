//
//  DGSKDrawEngineFactory.m
//  SpiralKit by Digital Generalists
//
//  Created by Mark Johnson on 7/19/13.
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

#import "DGSKDrawEngineFactory.h"

#import "SpiralKitTypes.h"

#import "DGSKDrawViewProtocol.h"

#import "DGSKDrawDataProviderProtocol.h"
#import "DGSKDrawContextStylingProviderProtocol.h"

#import "DGSKDrawEngineProtocol.h"

#import "DGSKStrokeDrawEngine.h"
#import "DGSKDouglasPeuckerStrokeDrawEngine.h"
#import "DGSKInterpolatedCacheDrawEngine.h"
#import "DGSKBezierCurveInterpolatedCacheDrawEngine.h"
#import "DGSKQuadCurveInterpolatedCacheDrawEngine.h"
#import "DGSKSingleStrokeCacheDrawEngine.h"

@implementation DGSKDrawEngineFactory

+ (id<DGSKDrawEngineProtocol>) createInstanceForDrawView:(UIView<DGSKDrawViewProtocol> *)drawView withStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider data:(id<DGSKDrawDataProviderProtocol>)data
{
    id<DGSKDrawEngineProtocol> engine = nil;
    
    // NOTE:  To enable dynamic selection of different drawing algorthims (not effects or styles, but the
    // raw-stroke calculation), this factory (and likely the draw view classes) will need to be augmented to apply
    // the appropriate engine to a view on-demand.
    
    if ((stylingProvider) && ([stylingProvider drawToolType] == DGSKDrawToolTypeHighlighter))
    {
        // NOTE:  The highlighter only works as expected with the single-stroke cache draw engine.  In fact, the
        // single-stroke cache draw engine was created specifically to enable the highlighter effect.  Feel free
        // to swap out the draw engine to see how the other draw algorithms effect the highlighter effect behavior.
        engine = [[DGSKSingleStrokeCacheDrawEngine alloc] initWithView:drawView stylingProvider:stylingProvider data:data];
    }
    else
    {
        // NOTE:  To select a specific stroke drawing implementation, change this class to return the appropriate
        // engine when an engine is requested.
        
        // NOTE:  The stroke-based draw engines are provided as examples of alternatives to non-bitmap-cache
        // draw engines.  Stroke-based engines are a good fit for composing drawings from point data, but given
        // their recalculative nature, they tend to not work well for "live" drawing UIs.
        // If you have the point data already stored and simply need to re-create the drawing, these engines could
        // be a good fit for those scenarios.
        //engine = [[DGSKStrokeDrawEngine alloc] initWithView:drawView stylingProvider:stylingProvider data:data];
        //engine = [[DGSKDouglasPeuckerStrokeDrawEngine alloc] initWithView:drawView stylingProvider:stylingProvider data:data];
        
        // NOTE:  The bitmap-cache-based draw engines are more sophisticated than the stroke-based engines and will work
        // better for applications that implement "live" drawing on the screen.
        //engine = [[DGSKInterpolatedCacheDrawEngine alloc] initWithView:drawView stylingProvider:stylingProvider data:data];
        //engine = [[DGSKQuadCurveInterpolatedCacheDrawEngine alloc] initWithView:drawView stylingProvider:stylingProvider data:data];
        engine = [[DGSKBezierCurveInterpolatedCacheDrawEngine alloc] initWithView:drawView stylingProvider:stylingProvider data:data];
        //engine = [[DGSKSingleStrokeCacheDrawEngine alloc] initWithView:drawView stylingProvider:stylingProvider data:data];
    }
    
    return engine;
}
@end
