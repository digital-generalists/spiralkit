//
//  DGSKInterpolatedCacheDrawEngine.m
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
 * A primary source for the inspiration of the behavior of this type of class was
 * http://www.effectiveui.com/blog/2011/12/02/how-to-build-a-simple-painting-app-for-ios/
 */

#import "DGSKInterpolatedCacheDrawEngine.h"

#import <tgmath.h>

#import "DGSKDrawContextStylingProviderProtocol.h"
#import "DGSKDrawDataProviderProtocol.h"
#import "DGSKCacheDrawDataProviderProtocol.h"
#import "DGSKStrokeDrawDataProviderProtocol.h"
#import "DGSKStrokeDataProviderProtocol.h"

#import "DGSKDrawUtils.h"

@interface DGSKInterpolatedCacheDrawEngine()

@property (nonatomic, strong) id<DGSKStrokeDataProviderProtocol> activeStroke;
// This typed version of the draw data should always reference the original draw data
// object, just properly cast.
// Raw stroke data is captured as metadata but is not used for "live" or "traditional"
// page rendering.
@property (nonatomic, strong) id<DGSKStrokeDrawDataProviderProtocol> typedStrokeDrawData;
// This typed version of the draw data should always reference the original draw data
// object, just properly cast.
@property (nonatomic, strong) id<DGSKCacheDrawDataProviderProtocol> typedDrawData;

@end


@implementation DGSKInterpolatedCacheDrawEngine

@synthesize activeStroke = _activeStroke;

@synthesize activePoint0 = _activePoint0;
@synthesize activePoint1 = _activePoint1;
@synthesize activePoint2 = _activePoint2;
@synthesize activePoint3 = _activePoint3;

@synthesize dirtyRect1 = _dirtyRect1;
@synthesize dirtyRect2 = _dirtyRect2;

- (id) initWithView:(UIView<DGSKDrawViewProtocol> *)hostView stylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)stylingProvider data:(id<DGSKDrawDataProviderProtocol>)drawData
{
    self = [super initWithView:hostView stylingProvider:stylingProvider data:drawData];
    if (self)
    {
        if (self.hostView)
        {
            self.hostView.drawEngine = self;
        }

        self.typedDrawData = nil;
        self.typedStrokeDrawData = nil;
        
        self.refreshRate = 2;
        
        self.activePoint0 = CGPointMake(-1, -1);
        self.activePoint1 = CGPointMake(-1, -1);
        self.activePoint2 = CGPointMake(-1, -1);
        self.activePoint3 = CGPointMake(-1, -1);
        
        self.dirtyRect1 = CGRectMake(-1, -1, -1, -1);
        self.dirtyRect2 = CGRectMake(-1, -1, -1, -1);
        
        if (![self.drawData conformsToProtocol:@protocol(DGSKCacheDrawDataProviderProtocol)])
        {
            self = nil;
        }
        else
        {
            self.typedDrawData = self.drawData;
            if ([self.drawData conformsToProtocol:@protocol(DGSKStrokeDrawDataProviderProtocol)])
            {
                self.typedStrokeDrawData = self.drawData;
            }
            self.activeStroke = nil;
        }
        // It may be nice to have a preloaded bitmap paint right here for when the page
        // transitions.  Only worth it if the page contents paint faster on transition.
        // Everything else is spot on.
    }
    return self;
}

- (void) beginCapture
{
    self.activePoint0 = CGPointMake(-1, -1);
    self.activePoint1 = CGPointMake(-1, -1);
    self.activePoint2 = CGPointMake(-1, -1);
    self.activePoint3 = CGPointMake(-1, -1);
    
    self.dirtyRect1 = CGRectMake(-1, -1, -1, -1);
    self.dirtyRect2 = CGRectMake(-1, -1, -1, -1);
    
    self.processedTouchesForActiveStroke = 0;
    
    self.activeStroke = nil;
    self.activeStroke = [self.typedStrokeDrawData createStrokeInstance];
    
    [self.stylingProvider resetEffects];
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
    
    [self.typedStrokeDrawData addStroke:self.activeStroke];
    
    [self.typedDrawData strokeFinalized];
    
    [self establishDrawRegion:self.activePoint0 point2:self.activePoint3];
    
    // Need to explicitly call a draw here to handle things like a single point click (i.e.
    // period in a sentence) that are exclusively handled by an end-draw call.
    [self draw:self.hostView.frame];
    
    self.activePoint0 = CGPointMake(-1, -1);
    self.activePoint1 = CGPointMake(-1, -1);
    self.activePoint2 = CGPointMake(-1, -1);
    self.activePoint3 = CGPointMake(-1, -1);
    
    self.dirtyRect1 = CGRectMake(-1, -1, -1, -1);
    self.dirtyRect2 = CGRectMake(-1, -1, -1, -1);
    
    self.processedTouchesForActiveStroke = 0;
    
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
    
    [self.typedDrawData strokeFinalized];
    
    self.activeStroke = nil;
    
    [self.stylingProvider resetEffects];
}

- (void) draw:(CGRect)invalidatedRegion
{
    CGSize size = self.hostView.bounds.size;
    
    CGContextRef context = NULL;
    
    // We don't actually need to create a retina-scale bitmap for the drawing.  It consumes a
    // ton more memory and doesn't appear to increase crispness of the drawing.
    CGFloat scale = 1.0f;
    CGImageAlphaInfo alphaSpecifer = kCGImageAlphaPremultipliedLast;
    while (context == NULL)
    {
        // This feels a little fast and loose, but seems to be working.
        // The enum walks through alpha channel support first, so that
        // will effectively give us progressive degredation.
        // From a production standpoint, it still feels more "lucky"
        // than I would like.
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

    CGContextRef screenContext = UIGraphicsGetCurrentContext();
    if (screenContext != NULL)
    {
        CGContextDrawImage(screenContext, self.hostView.frame, self.typedDrawData.contentBitmap.CGImage);
    }
}

- (void) restoreViewImage:(UIImage *)viewImage toContext:(CGContextRef)context
{
    if (viewImage != nil)
    {
        CGContextDrawImage(context, self.hostView.frame, [viewImage CGImage]);
    }
}

- (void) performDrawWithContext:(CGContextRef)context
{
    if (self.processedTouchesForActiveStroke > CACHE_MINIMUM_DRAW_POINT_THRESHOLD)
    {
        CGContextBeginPath(context);
        
        NSArray *points = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:self.activePoint0], [NSValue valueWithCGPoint:self.activePoint3], nil];
        [self.stylingProvider applyPropertiesToContext:context withEffectsBasedOnPoints:points];
        
        NSArray *interpolatedPoints = [DGSKDrawUtils interpolatePoints:self.activePoint0 point1:self.activePoint1 point2:self.activePoint2 point3:self.activePoint3];
        //DGSKLog(@"%i", [interpolatedPoints count]);
        
        CGContextMoveToPoint(context, self.activePoint1.x, self.activePoint1.y);
        if ([interpolatedPoints count] >= 2)
        {
            CGContextAddLineToPoint(context, [[interpolatedPoints objectAtIndex:1] CGPointValue].x, [[interpolatedPoints objectAtIndex:1] CGPointValue].y);
            CGContextMoveToPoint(context, [[interpolatedPoints objectAtIndex:1] CGPointValue].x, [[interpolatedPoints objectAtIndex:1] CGPointValue].y);
            CGContextAddLineToPoint(context, self.activePoint2.x, self.activePoint2.y);
        }
        else
        {
            DGSKLog(@"%@", @"interpolatePoints returned too few points to draw");
            CGContextAddLineToPoint(context, self.activePoint2.x, self.activePoint2.y);
        }
        
        CGContextStrokePath(context);
        
        [self establishDrawRegion:self.activePoint0 point2:self.activePoint3];
    }
}

- (void) establishDrawRegion:(CGPoint) point1 point2:(CGPoint) point2
{
    NSInteger drawX1 = 0;
    NSInteger drawY1 = 0;
    NSInteger drawX2 = 0;
    NSInteger drawY2 = 0;
    NSInteger drawWidth1 = 0;
    NSInteger drawHeight1 = 0;
    NSInteger drawWidth2 = 0;
    NSInteger drawHeight2 = 0;
    NSInteger boundsWidth = self.hostView.bounds.size.width;
    NSInteger boundsHeight = self.hostView.bounds.size.height;
    drawX1 = point1.x-75;
    drawY1 = point1.y-75;
    drawX2 = point2.x-75;
    drawY2 = point2.y-75;
    drawWidth1 = 150;
    drawHeight1 = 150;
    drawWidth2 = 150;
    drawHeight2 = 150;
    if (drawX1 < 0)
    {
        drawX1 = 0;
    }
    if (drawY1 < 0)
    {
        drawY1 = 0;
    }
    if (drawX2 < 0)
    {
        drawX2 = 0;
    }
    if (drawY2 < 0)
    {
        drawY2 = 0;
    }
    if ((drawX1+drawWidth1) > boundsWidth)
    {
        drawWidth1 = boundsWidth - drawX1;
    }
    if ((drawY1+drawHeight1) > boundsHeight)
    {
        drawHeight1 = boundsHeight - drawY1;
    }
    if ((drawX2+drawWidth2) > boundsWidth)
    {
        drawWidth2 = boundsWidth - drawX2;
    }
    if ((drawY2+drawHeight2) > boundsHeight)
    {
        drawHeight2 = boundsHeight - drawY1;
    }
    //DGSKLog(@"Draw width 1: %d", drawWidth1);
    //DGSKLog(@"Draw height 1: %d", drawHeight1);
    //DGSKLog(@"Draw width 2: %d", drawWidth2);
    //DGSKLog(@"Draw height 2: %d", drawHeight2);
    self.dirtyRect1 = CGRectMake(drawX1, drawY1, drawWidth1, drawHeight1);
    self.dirtyRect2 = CGRectMake(drawX2, drawY2, drawWidth2, drawHeight2);
    
    if (((self.dirtyRect1.origin.x > -1) && (self.dirtyRect1.origin.y > -1)) && ((self.dirtyRect2.origin.x > -1) && (self.dirtyRect2.origin.y > -1)))
    {
        [self.hostView setNeedsDisplayInRect:CGRectUnion(self.dirtyRect1, self.dirtyRect2)];
    }
}

- (void) prepareForUnload
{
    _activeStroke = nil;
    _typedDrawData = nil;
    _typedStrokeDrawData = nil;
    
    [super prepareForUnload];
}

@end
