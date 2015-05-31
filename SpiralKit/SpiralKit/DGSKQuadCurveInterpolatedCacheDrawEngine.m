//
//  DGSKQuadCurveInterpolatedCacheDrawEngine.m
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

#import "DGSKQuadCurveInterpolatedCacheDrawEngine.h"

#import "DGSKDrawContextStylingProviderProtocol.h"

#import "DGSKDrawUtils.h"

@interface DGSKQuadCurveInterpolatedCacheDrawEngine()

@end

@implementation DGSKQuadCurveInterpolatedCacheDrawEngine

- (void) performDrawWithContext:(CGContextRef)context
{
    if (self.processedTouchesForActiveStroke > CACHE_MINIMUM_DRAW_POINT_THRESHOLD)
    {
        NSArray *points = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:self.activePoint0], [NSValue valueWithCGPoint:self.activePoint3], nil];
        [self.stylingProvider applyPropertiesToContext:context withEffectsBasedOnPoints:points];
        
        CGContextBeginPath(context);
        
        CGPoint midPoint1 = [DGSKDrawUtils calculateMidBetweenPoint1:self.activePoint1 point2:self.activePoint2];
        CGPoint midPoint2 = [DGSKDrawUtils calculateMidBetweenPoint1:self.activePoint0 point2:self.activePoint1];
        
        CGContextMoveToPoint(context, midPoint1.x, midPoint1.y);
        CGContextAddQuadCurveToPoint(context, midPoint1.x, midPoint1.y, midPoint2.x, midPoint2.y);
        
        CGContextStrokePath(context);
        
        [self establishDrawRegion:midPoint1 point2:midPoint2];
    }
}

@end
