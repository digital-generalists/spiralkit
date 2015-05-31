//
//  DGSKBezierCurveInterpolatedCacheDrawEngine.m
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

#import "DGSKBezierCurveInterpolatedCacheDrawEngine.h"

#import "DGSKDrawContextStylingProviderProtocol.h"

#import "DGSKDrawUtils.h"


@implementation DGSKBezierCurveInterpolatedCacheDrawEngine

- (void) performDrawWithContext:(CGContextRef)context
{
    if (self.processedTouchesForActiveStroke > CACHE_MINIMUM_DRAW_POINT_THRESHOLD)
    {
        CGContextBeginPath(context);
        
        NSArray *points = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:self.activePoint0], [NSValue valueWithCGPoint:self.activePoint3], nil];
        [self.stylingProvider applyPropertiesToContext:context withEffectsBasedOnPoints:points];
        
        NSArray *interpolatedPoints = [DGSKDrawUtils interpolatePoints:self.activePoint0 point1:self.activePoint1 point2:self.activePoint2 point3:self.activePoint3];
        
        CGContextMoveToPoint(context, self.activePoint1.x, self.activePoint1.y);
        if ([interpolatedPoints count] >= 2)
        {
            CGContextAddCurveToPoint(context, [[interpolatedPoints objectAtIndex:0] CGPointValue].x, [[interpolatedPoints objectAtIndex:0] CGPointValue].y, [[interpolatedPoints objectAtIndex:1] CGPointValue].x, [[interpolatedPoints objectAtIndex:1] CGPointValue].y, self.activePoint2.x, self.activePoint2.y);
        }
        else
        {
            DGSKLog(@"%@", @"interpolatePoints returned too few points to draw");
            CGContextAddCurveToPoint(context, self.activePoint1.x, self.activePoint1.y, self.activePoint2.x, self.activePoint2.y, self.activePoint2.x, self.activePoint2.y);
        }
        
        CGContextStrokePath(context);
        
        [self establishDrawRegion:self.activePoint0 point2:self.activePoint3];
    }
}

@end
