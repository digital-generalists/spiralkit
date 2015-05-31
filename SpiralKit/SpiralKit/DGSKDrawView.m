//
//  DGSKDrawView.m
//  SpiralKit by Digital Generalists
//
//  Created by Mark Johnson on 5/7/12.
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
 * A primary source for the initial behavior of this type of class was
 * http://www.effectiveui.com/blog/2011/12/02/how-to-build-a-simple-painting-app-for-ios/
 */

#import "DGSKDrawView.h"

#import "DGSKDrawEngineProtocol.h"

@interface DGSKDrawView ()

- (id) initWithFrame:(CGRect)frame;

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

- (void) drawRect:(CGRect)rect;

@end


@implementation DGSKDrawView

// NOTE:  I'm not in love with the circular relationship between the
// draw engine and the draw view, but given how they interact, it's
// difficult to avoid.  Probably should have a proxy object sit between
// the two.
@synthesize drawEngine = _drawEngine;

- (id) initWithFrame:(CGRect)frame
{
    // This doesn't get called from storyboard initialization.
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.drawEngine beginCapture];
    
    for (UITouch *touch in touches)
    {
        CGPoint touchPoint = [touch locationInView:self];
        //DGSKLog(@"Begin: %@", NSStringFromCGPoint(touchPoint));        
        
        [self.drawEngine addFirstPoint:touchPoint];
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    for (UITouch *touch in touches)
    {
        CGPoint touchPoint = [touch locationInView:self];
        //DGSKLog(@"Move: %@", NSStringFromCGPoint(touchPoint));        
        
        [self.drawEngine addPoint:touchPoint];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    for (UITouch *touch in touches)
    {
        CGPoint touchPoint = [touch locationInView:self];
        //DGSKLog(@"End: %@", NSStringFromCGPoint(touchPoint));
        
        [self.drawEngine addPoint:touchPoint];
    }
    
    [self.drawEngine endCapture];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    //for (UITouch *touch in touches)
    //{
    //    CGPoint touchPoint = [touch locationInView:self];
    //    DGSKLog(@"Cancelled: %@", NSStringFromCGPoint(touchPoint));
    //}
    
    [self.drawEngine cancelCapture];
}

// Only override drawRect if you perform custom drawing.
// An empty implementation can adversely affect performance.
- (void) drawRect:(CGRect)rect
{
    //DGSKLog(@"rect: %@", NSStringFromCGRect(rect));
    [self.drawEngine draw:rect];
}

- (void) prepareForUnload
{
    [self.drawEngine prepareForUnload];
}

@end
