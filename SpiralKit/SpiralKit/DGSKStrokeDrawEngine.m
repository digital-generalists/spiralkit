//
//  DGSKStrokeDrawEngine.m
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

#import "DGSKStrokeDrawEngine.h"

#import "DGSKDrawContextStylingProviderProtocol.h"

#import "DGSKDrawDataProviderProtocol.h"
#import "DGSKStrokeDataProviderProtocol.h"
#import "DGSKStrokeDrawDataProviderProtocol.h"

#import "DGSKDrawUtils.h"

@interface DGSKStrokeDrawEngine()

- (void) performDrawWithContext:(CGContextRef)context;

- (void) drawStroke:(id<DGSKStrokeDataProviderProtocol>)stroke withContext:(CGContextRef)context;
- (void) drawPointPath:(NSArray *)points withContext:(CGContextRef)context;

@property (nonatomic, strong) id<DGSKStrokeDataProviderProtocol> activeStroke;
// This typed version of the draw data should always reference the original draw data
// object, just properly cast.
@property (nonatomic, strong) id<DGSKStrokeDrawDataProviderProtocol> typedDrawData;

@end


@implementation DGSKStrokeDrawEngine

@synthesize activeStroke = _activeStroke;

- (id) initWithView:(UIView<DGSKDrawViewProtocol> *)hostView stylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider data:(id<DGSKDrawDataProviderProtocol>)drawData
{
    self = [super initWithView:hostView  stylingProvider:stylingProvider data:drawData];
    if (self)
    {
        if (self.hostView)
        {
            self.hostView.drawEngine = self;
        }
        
        self.typedDrawData = nil;
        
        if (![self.drawData conformsToProtocol:@protocol(DGSKStrokeDrawDataProviderProtocol)])
        {
            self = nil;
        }
        else
        {
            self.typedDrawData = self.drawData;
            self.activeStroke = nil;
        }
    }
    return self;
}

- (void) beginCapture
{
    [self.stylingProvider resetEffects];
    self.activeStroke = nil;
    self.processedTouchesForActiveStroke = 0;
    
    self.activeStroke = [self.typedDrawData createStrokeInstance];
}

- (void) addFirstPoint:(CGPoint)point
{
    [self.activeStroke addDrawPoint:point];
}

- (void) addPoint:(CGPoint)point
{
    self.processedTouchesForActiveStroke++;
    
    if ((self.processedTouchesForActiveStroke % self.refreshRate) == 0)
    {
        [self.activeStroke addDrawPoint:point];

        [self.hostView setNeedsDisplay];
    }
}

- (void) endCapture
{
    if ([self.activeStroke numberOfPoints] < 4)
    {
        CGPoint singlePoint = [[self.activeStroke.drawPoints objectAtIndex:0] CGPointValue];
        
        self.activeStroke = [self.typedDrawData createStrokeInstance];
        [self.activeStroke addDrawPoint:singlePoint];
        [self.activeStroke addDrawPoint:CGPointMake(singlePoint.x+1, singlePoint.y)];
        [self.activeStroke addDrawPoint:CGPointMake(singlePoint.x, singlePoint.y+1)];
        [self.activeStroke addDrawPoint:CGPointMake(singlePoint.x+1, singlePoint.y+1)];
    }

    [self.typedDrawData addStroke:self.activeStroke];
    
    [self.typedDrawData strokeFinalized];
    
    [self.hostView setNeedsDisplay];
    
    [self.stylingProvider resetEffects];
}

- (void) cancelCapture
{
    [self.typedDrawData strokeFinalized];
    
    self.processedTouchesForActiveStroke = 0;
    self.activeStroke = nil;
    
    [self.stylingProvider resetEffects];
}

- (void) draw:(CGRect)invalidatedRegion
{
    // Even through this method doesn't action off of the invalidation rect,
    // the rect is still appears to be applied by by the system paint infrastructure.
    // To test, set the invalidation rect to something small in the setNeedsDispayInRect
    // calls.  The invalidated region is passed to this method correctly and only the region
    // specified by the invalidation rect is redrawn on the screen even though it isn't
    // referenced directly here.
    [self performDrawWithContext:UIGraphicsGetCurrentContext()];
}

- (void) performDrawWithContext:(CGContextRef)context
{
    [self drawStroke:self.activeStroke withContext:context];
    for (id<DGSKStrokeDataProviderProtocol> stroke in self.typedDrawData.drawStrokes)
    {
        [self drawStroke:stroke withContext:context];
    }
}

- (void) drawStroke:(id<DGSKStrokeDataProviderProtocol>)stroke withContext:(CGContextRef)context
{
    if (stroke.numberOfPoints > STROKE_MINIMUM_DRAW_POINT_THRESHOLD)
    {
        [self drawPointPath:stroke.drawPoints withContext:context];
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
            
            NSArray *interpolatedPoints = [DGSKDrawUtils interpolatePoints:point0 point1:point1 point2:point2 point3:point3];
            
            CGContextMoveToPoint(context, point1.x, point1.y);
            if ([interpolatedPoints count] >= 2)
            {
                CGContextAddCurveToPoint(context, [[interpolatedPoints objectAtIndex:0] CGPointValue].x, [[interpolatedPoints objectAtIndex:0] CGPointValue].y, [[interpolatedPoints objectAtIndex:1] CGPointValue].x, [[interpolatedPoints objectAtIndex:1] CGPointValue].y, point2.x, point2.y);
            }
            else
            {
                DGSKLog(@"%@", @"interpolatePoints returned too few points to draw");
                CGContextAddCurveToPoint(context, point1.x, point1.y, point2.x, point2.y, point2.x, point2.y);
            }
            
            CGContextStrokePath(context);
        }
    }
}

- (void) prepareForUnload
{
    _activeStroke = nil;
    _typedDrawData = nil;
    
    [super prepareForUnload];
}

@end
