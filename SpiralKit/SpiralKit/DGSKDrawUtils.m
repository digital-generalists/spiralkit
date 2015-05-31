//
//  DGSKDataUtils.m
//  SpiralKit by Digital Generalists
//
//  Created by Mark Johnson on 6/14/12.
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

#import "Foundation/Foundation.h"

#import "DGSKDrawUtils.h"

@interface DGSKDrawUtils ()

+ (CGFloat)perpendicularDistance:(CGPoint)point lineA:(CGPoint)lineA lineB:(CGPoint)lineB;

@end


@implementation DGSKDrawUtils

+ (CGFloat) distanceBetweenPoint1:(CGPoint) point1 point2:(CGPoint) point2
{
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy);
}

+ (CGPoint) calculateMidBetweenPoint1:(CGPoint) point1 point2: (CGPoint) point2
{
    return CGPointMake((point1.x + point2.x) * 0.5, (point1.y + point2.y) * 0.5);
}

+ (NSArray *)douglasPeucker:(NSArray *)points epsilon:(CGFloat)epsilon
{
    NSUInteger count = [points count];
    if(count < 3) 
    {
        return points;
    }
    
    //Find the point with the maximum distance
    CGFloat dmax = 0;
    NSUInteger index = 0;
    for(NSUInteger i = 1; i < count - 1; i++) {
        CGPoint point = [[points objectAtIndex:i] CGPointValue];
        CGPoint lineA = [[points objectAtIndex:0] CGPointValue];
        CGPoint lineB = [[points objectAtIndex:count - 1] CGPointValue];
        CGFloat d = [self perpendicularDistance:point lineA:lineA lineB:lineB];
        if(d > dmax) {
            index = i;
            dmax = d;
        }
    }
    
    //If max distance is greater than epsilon, recursively simplify
    NSArray *resultList;
    if(dmax > epsilon) 
    {
        NSArray *recResults1 = [DGSKDrawUtils douglasPeucker:[points subarrayWithRange:NSMakeRange(0, index + 1)] epsilon:epsilon];
        
        NSArray *recResults2 = [DGSKDrawUtils douglasPeucker:[points subarrayWithRange:NSMakeRange(index, count - index)] epsilon:epsilon];
        
        NSMutableArray *tmpList = [NSMutableArray arrayWithArray:recResults1];
        [tmpList removeLastObject];
        [tmpList addObjectsFromArray:recResults2];
        resultList = tmpList;
    } 
    else 
    {
        resultList = [NSArray arrayWithObjects:[points objectAtIndex:0], [points objectAtIndex:count - 1],nil];
    }
    
    return resultList;
}

+ (CGFloat)perpendicularDistance:(CGPoint)point lineA:(CGPoint)lineA lineB:(CGPoint)lineB
{
    CGPoint v1 = CGPointMake(lineB.x - lineA.x, lineB.y - lineA.y);
    CGPoint v2 = CGPointMake(point.x - lineA.x, point.y - lineA.y);
    CGFloat lenV1 = sqrt(v1.x * v1.x + v1.y * v1.y);
    CGFloat lenV2 = sqrt(v2.x * v2.x + v2.y * v2.y);
    CGFloat angle = acos((v1.x * v2.x + v1.y * v2.y) / (lenV1 * lenV2));
    return sin(angle) * lenV2;
}

+ (NSArray *)catmullRomSpline:(NSArray *)points segments:(NSUInteger)segments
{
    NSUInteger count = [points count];
    if(count < 4) 
    {
        return points;
    }
    
    CGFloat b[segments][4];
    {
        // precompute interpolation parameters
        CGFloat t = 0.0f;
        CGFloat dt = 1.0f/(CGFloat)segments;
        for (NSUInteger i = 0; i < segments; i++, t+=dt) 
        {
            CGFloat tt = t*t;
            CGFloat ttt = tt * t;
            b[i][0] = 0.5f * (-ttt + 2.0f*tt - t);
            b[i][1] = 0.5f * (3.0f*ttt -5.0f*tt +2.0f);
            b[i][2] = 0.5f * (-3.0f*ttt + 4.0f*tt + t);
            b[i][3] = 0.5f * (ttt - tt);
        }
    }
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    {
        NSUInteger i = 0; // first control point
        [resultArray addObject:[points objectAtIndex:0]];
        for (NSUInteger j = 1; j < segments; j++) 
        {
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            CGPoint pointIp2 = [[points objectAtIndex:(i + 2)] CGPointValue];
            CGFloat px = (b[j][0]+b[j][1])*pointI.x + b[j][2]*pointIp1.x + b[j][3]*pointIp2.x;
            CGFloat py = (b[j][0]+b[j][1])*pointI.y + b[j][2]*pointIp1.y + b[j][3]*pointIp2.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    
    for (NSUInteger i = 1; i < count-2; i++) {
        // the first interpolated point is always the original control point
        [resultArray addObject:[points objectAtIndex:i]];
        for (NSUInteger j = 1; j < segments; j++) 
        {
            CGPoint pointIm1 = [[points objectAtIndex:(i - 1)] CGPointValue];
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            CGPoint pointIp2 = [[points objectAtIndex:(i + 2)] CGPointValue];
            CGFloat px = b[j][0]*pointIm1.x + b[j][1]*pointI.x + b[j][2]*pointIp1.x + b[j][3]*pointIp2.x;
            CGFloat py = b[j][0]*pointIm1.y + b[j][1]*pointI.y + b[j][2]*pointIp1.y + b[j][3]*pointIp2.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    
    {
        NSUInteger i = count-2; // second to last control point
        [resultArray addObject:[points objectAtIndex:i]];
        for (NSUInteger j = 1; j < segments; j++) 
        {
            CGPoint pointIm1 = [[points objectAtIndex:(i - 1)] CGPointValue];
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            CGFloat px = b[j][0]*pointIm1.x + b[j][1]*pointI.x + (b[j][2]+b[j][3])*pointIp1.x;
            CGFloat py = b[j][0]*pointIm1.y + b[j][1]*pointI.y + (b[j][2]+b[j][3])*pointIp1.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    // the very last interpolated point is the last control point
    [resultArray addObject:[points objectAtIndex:(count - 1)]]; 
    
    return resultArray;
}

+ (NSArray *) interpolatePoints:(CGPoint)point0 point1:(CGPoint)point1 point2:(CGPoint)point2 point3:(CGPoint)point3
{
    double x0 = (point0.x > -1) ? point0.x : point1.x; //after 4 touches we should have a back anchor point, if not, use the current anchor point
    double y0 = (point0.y > -1) ? point0.y : point1.y; //after 4 touches we should have a back anchor point, if not, use the current anchor point
    double x1 = point1.x;
    double y1 = point1.y;
    double x2 = point2.x;
    double y2 = point2.y;
    double x3 = point3.x;
    double y3 = point3.y;
    
    double xc1 = (x0 + x1) / 2.0;
    double yc1 = (y0 + y1) / 2.0;
    double xc2 = (x1 + x2) / 2.0;
    double yc2 = (y1 + y2) / 2.0;
    double xc3 = (x2 + x3) / 2.0;
    double yc3 = (y2 + y3) / 2.0;
    
    double len1 = sqrt((x1-x0) * (x1-x0) + (y1-y0) * (y1-y0));
    double len2 = sqrt((x2-x1) * (x2-x1) + (y2-y1) * (y2-y1));
    double len3 = sqrt((x3-x2) * (x3-x2) + (y3-y2) * (y3-y2));
    
    double k1 = len1 / (len1 + len2);
    double k2 = len2 / (len2 + len3);
    
    double xm1 = xc1 + (xc2 - xc1) * k1;
    double ym1 = yc1 + (yc2 - yc1) * k1;
    double xm2 = xc2 + (xc3 - xc2) * k2;
    double ym2 = yc2 + (yc3 - yc2) * k2;
    
    double smooth_value = 0.5;
    CGFloat ctrl1_x = xm1 + (xc2 - xm1) * smooth_value + x1 - xm1;
    CGFloat ctrl1_y = ym1 + (yc2 - ym1) * smooth_value + y1 - ym1;
    CGFloat ctrl2_x = xm2 + (xc2 - xm2) * smooth_value + x2 - xm2;
    CGFloat ctrl2_y = ym2 + (yc2 - ym2) * smooth_value + y2 - ym2;
    
    CGPoint resultPoint1 = CGPointMake(ctrl1_x, ctrl1_y);
    CGPoint resultPoint2 = CGPointMake(ctrl2_x, ctrl2_y);
    
    NSArray *interpolatedPoints = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:resultPoint1], [NSValue valueWithCGPoint:resultPoint2], nil];
    
    return interpolatedPoints;
}

@end
