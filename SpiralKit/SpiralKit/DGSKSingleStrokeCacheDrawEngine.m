//
//  DGSKInitialStrokeBezierCurveInterpolatedCacheDrawEngine.m
//  SpiralKit by Digital Generalists
//
//  Created by Mark Johnson on 2/15/13.
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

#import "DGSKSingleStrokeCacheDrawEngine.h"

#import <tgmath.h>

#import "DGSKDrawContextStylingProviderProtocol.h"

#import "DGSKDrawDataProviderProtocol.h"
#import "DGSKCacheDrawDataProviderProtocol.h"
#import "DGSKStrokeDrawDataProviderProtocol.h"
#import "DGSKStrokeDataProviderProtocol.h"

#import "DGSKDrawUtils.h"

@interface DGSKSingleStrokeCacheDrawEngine()

- (void) drawStroke:(id<DGSKStrokeDataProviderProtocol>)stroke withContext:(CGContextRef)context;
- (void) drawPointPath:(NSArray *)points withContext:(CGContextRef)context;

@property (nonatomic, strong) id<DGSKStrokeDataProviderProtocol> activeStroke;
// This typed version of the draw data should always reference the original draw data
// object, just properly cast.
@property (nonatomic, strong) id<DGSKStrokeDrawDataProviderProtocol> strokeDrawData;
// This typed version of the draw data should always reference the original draw data
// object, just properly cast.
@property (nonatomic, strong) id<DGSKCacheDrawDataProviderProtocol> typedDrawData;

@end


@implementation DGSKSingleStrokeCacheDrawEngine

@synthesize activeStroke = _activeStroke;
@synthesize strokeDrawData = _strokeDrawData;

- (id) initWithView:(UIView<DGSKDrawViewProtocol> *)hostView stylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider data:(id<DGSKDrawDataProviderProtocol>)drawData
{
    self = [super initWithView:hostView  stylingProvider:stylingProvider data:drawData];
    if (self)
    {
        self.strokeDrawData = nil;
        self.typedDrawData = nil;
        
        if (![self.drawData conformsToProtocol:@protocol(DGSKStrokeDrawDataProviderProtocol)])
        {
            self = nil;
        }
        else
        {
            self.strokeDrawData = self.drawData;
            self.activeStroke = nil;
        }
        if (![self.drawData conformsToProtocol:@protocol(DGSKCacheDrawDataProviderProtocol)])
        {
            self = nil;
        }
        else
        {
            self.typedDrawData = self.drawData;
        }
    }
    return self;
}

- (void) beginCapture
{
    [self.stylingProvider resetEffects];
    
    self.activePoint0 = CGPointMake(-1, -1);
    self.activePoint1 = CGPointMake(-1, -1);
    self.activePoint2 = CGPointMake(-1, -1);
    self.activePoint3 = CGPointMake(-1, -1);
    
    self.dirtyRect1 = CGRectMake(-1, -1, -1, -1);
    self.dirtyRect2 = CGRectMake(-1, -1, -1, -1);
    
    self.activeStroke = nil;
    self.processedTouchesForActiveStroke = 0;
    
    self.activeStroke = [self.strokeDrawData createStrokeInstance];
}

- (void) addFirstPoint:(CGPoint)point
{
    self.activePoint0 = point;
    self.activePoint1 = point;
    self.activePoint2 = point;
    self.activePoint3 = point;

    [self.activeStroke addDrawPoint:point];
}

- (void) addPoint:(CGPoint)point
{
    self.processedTouchesForActiveStroke++;
    
    if ((self.processedTouchesForActiveStroke % self.refreshRate) == 0)
    {
        self.activePoint0 = self.activePoint1;
        self.activePoint1 = self.activePoint2;
        self.activePoint2 = self.activePoint3;
        self.activePoint3 = point;
        
        [self.activeStroke addDrawPoint:point];
        
        [self establishDrawRegion:self.activePoint0 point2:self.activePoint3];
    }
}

- (void) endCapture
{
    if (CGPointEqualToPoint(self.activePoint0, self.activePoint1) &&
        CGPointEqualToPoint(self.activePoint0, self.activePoint2) &&
        CGPointEqualToPoint(self.activePoint0, self.activePoint3))
    {
        self.activePoint1 = CGPointMake(self.activePoint1.x+1, self.activePoint1.y);
        self.activePoint2 = CGPointMake(self.activePoint2.x, self.activePoint2.y+1);
        self.activePoint3 = CGPointMake(self.activePoint3.x+1, self.activePoint3.y+1);
    }
    
    if ([self.activeStroke numberOfPoints] < 4)
    {
        CGPoint singlePoint = [[self.activeStroke.drawPoints objectAtIndex:0] CGPointValue];
        
        self.activeStroke = [self.strokeDrawData createStrokeInstance];
        [self.activeStroke addDrawPoint:singlePoint];
        [self.activeStroke addDrawPoint:CGPointMake(singlePoint.x+1, singlePoint.y)];
        [self.activeStroke addDrawPoint:CGPointMake(singlePoint.x, singlePoint.y+1)];
        [self.activeStroke addDrawPoint:CGPointMake(singlePoint.x+1, singlePoint.y+1)];
    }
    
    [self.strokeDrawData addStroke:self.activeStroke];
    
    [self establishDrawRegion:self.activePoint0 point2:self.activePoint3];
    
    [self drawToCacheImage];
    
    [self.typedDrawData strokeFinalized];
    
    [self.stylingProvider resetEffects];
}

- (void) cancelCapture
{
    self.activePoint0 = CGPointMake(-1, -1);
    self.activePoint1 = CGPointMake(-1, -1);
    self.activePoint2 = CGPointMake(-1, -1);
    self.activePoint3 = CGPointMake(-1, -1);
    
    self.dirtyRect1 = CGRectMake(-1, -1, -1, -1);
    self.dirtyRect2 = CGRectMake(-1, -1, -1, -1);
    
    self.processedTouchesForActiveStroke = 0;
    self.activeStroke = nil;
    
    [self.typedDrawData strokeFinalized];
    
    [self.stylingProvider resetEffects];
}

- (void) draw:(CGRect)invalidatedRegion
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    [self restoreViewImage:self.typedDrawData.contentBitmap toContext:context];
    
    [self performDrawWithContext:context];
}

- (void) drawToCacheImage
{
    CGSize size = self.hostView.bounds.size;
    
    CGContextRef context = NULL;
    
    // Don't actually need to create a retina-scale bitmap for the drawing.  It consumes a
    // ton more memory and doesn't appear to increase crispness of the drawing.
    CGFloat scale = 1.0f;
    CGImageAlphaInfo alphaSpecifer = kCGImageAlphaPremultipliedLast;
    while (context == NULL)
    {
        // This feels a little fast and loose, but seems to be working.
        // The enum walks through alpha channel support first, so that
        // will effectively give us progressive degredation.
        // Still feels more "lucky" than I would like.
        if (alphaSpecifer > 7)
        {
            return;
        }
        
        CGColorSpaceRef colorspace = [self.stylingProvider CreateStylingColorSpace]();
        context = CGBitmapContextCreate (NULL, size.width * scale, size.height * scale, 8, (floor(size.width) * scale * 4), colorspace, (CGBitmapInfo)alphaSpecifer);
        alphaSpecifer++;
        CGColorSpaceRelease(colorspace);
    }
    CGContextScaleCTM(context, scale, scale);
    
    [self restoreViewImage:self.typedDrawData.contentBitmap toContext:context];
    
    [self performDrawWithContext:context];
    
    CGImageRef cacheImage = CGBitmapContextCreateImage(context);
    // The bitmap has no inherent orientation.
    self.typedDrawData.contentBitmap = [UIImage imageWithCGImage:cacheImage scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
    CGImageRelease(cacheImage);
    CGContextRelease(context);
    
    self.activeStroke = nil;
    
    [self.hostView setNeedsDisplay];
}

- (void) performDrawWithContext:(CGContextRef)context
{
    // Only draw the active stroke.  Once the stroke is finalized, it will be written to cache.
    [self drawStroke:self.activeStroke withContext:context];
}

- (void) drawStroke:(id<DGSKStrokeDataProviderProtocol>)stroke withContext:(CGContextRef)context
{
    [self drawPointPath:stroke.drawPoints withContext:context];
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
        }
    }
    
    CGContextStrokePath(context);
}


- (void) prepareForUnload
{
    _activeStroke = nil;
    _typedDrawData = nil;
    _strokeDrawData = nil;
    
    [super prepareForUnload];
}

@end
