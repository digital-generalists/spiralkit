//
//  DGSKDouglasPeuckerStrokeDrawEngine.m
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
/*
 * The Douglas-Peucker algorithm implementation methods in this class are based
 * on work from https://github.com/andreac/lineSmooth
 */

#import "DGSKDouglasPeuckerStrokeDrawEngine.h"

#import "DGSKDrawContextStylingProviderProtocol.h"
#import "DGSKDrawDataProviderProtocol.h"
#import "DGSKStrokeDataProviderProtocol.h"

#import "DGSKDrawUtils.h"

#define DOUGLAS_PEUKER_DEFAULT_EPSILON 3;
#define DOUGLAS_PEUKER_DEFAULT_SEGEMENTS 6;

@interface DGSKDouglasPeuckerStrokeDrawEngine()

@end

@implementation DGSKDouglasPeuckerStrokeDrawEngine

@synthesize epsilon = _epsilon;
@synthesize segments = _segments;

- (id) initWithView:(UIView<DGSKDrawViewProtocol> *)hostView stylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider data:(id<DGSKDrawDataProviderProtocol>)drawData
{
    self = [super initWithView:hostView stylingProvider:stylingProvider data:drawData];
    if (self)
    {
        self.epsilon = DOUGLAS_PEUKER_DEFAULT_EPSILON;
        self.segments = DOUGLAS_PEUKER_DEFAULT_SEGEMENTS;
    }
    return self;
}

- (void) drawStroke:(id<DGSKStrokeDataProviderProtocol>)stroke withContext:(CGContextRef)context
{
    if (stroke.numberOfPoints > STROKE_MINIMUM_DRAW_POINT_THRESHOLD)
    {
        NSArray *generalizedPoints = [DGSKDrawUtils douglasPeucker:stroke.drawPoints epsilon:self.epsilon];
        NSArray *splinePoints = [DGSKDrawUtils catmullRomSpline:generalizedPoints segments:self.segments];
        
        [self drawPointPath:splinePoints withContext:context];
    }
}

- (void) drawPointPath:(NSArray *)points withContext:(CGContextRef)context
{
    CGContextBeginPath(context);
    Boolean firstPass = true;
    
    CGPoint point0 = CGPointMake(-1, -1);
    CGPoint point1 = point0;
    CGPoint point2 = point0;
    CGPoint point3 = point0;
    
    for (NSValue *value in points) 
    {
        CGPoint point = [value CGPointValue];
        if (firstPass)
        {
            point0 = point;
            point1 = point;
            point2 = point;
            point3 = point;
            
            CGContextMoveToPoint(context, point0.x, point0.y);
            firstPass = false;
        }
        else 
        {
            point0 = point1;
            point1 = point2;
            point2 = point3;
            point3 = point;
            
            NSArray *strokePoints = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:point0], [NSValue valueWithCGPoint:point3], nil];
            [self.stylingProvider applyPropertiesToContext:context withEffectsBasedOnPoints:strokePoints];
            
            CGContextMoveToPoint(context, point2.x, point2.y);
            CGContextAddLineToPoint(context, point.x, point.y);
            CGContextStrokePath(context);
        }
    }
}

@end
