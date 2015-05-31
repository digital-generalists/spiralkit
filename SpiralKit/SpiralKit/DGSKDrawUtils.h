//
//  DGSKDataUtils.h
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

#import <UIKit/UIKit.h>

@interface DGSKDrawUtils : NSObject

+ (CGFloat) distanceBetweenPoint1:(CGPoint) point1 point2:(CGPoint) point2;
+ (CGPoint) calculateMidBetweenPoint1:(CGPoint) point1 point2: (CGPoint) point2;

+ (NSArray *)douglasPeucker:(NSArray *)points epsilon:(CGFloat)epsilon;
+ (NSArray *)catmullRomSpline:(NSArray *)points segments:(NSUInteger)segments;

+ (NSArray *) interpolatePoints:(CGPoint)point0 point1:(CGPoint)point1 point2:(CGPoint)point2 point3:(CGPoint)point3;

@end
