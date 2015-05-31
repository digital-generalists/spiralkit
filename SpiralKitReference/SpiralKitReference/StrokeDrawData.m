//
//  StrokeDrawData.m
//  SpiralKitReference
//
//  Created by Mark Johnson on 4/26/15.
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

#import "StrokeDrawData.h"

@interface StrokeDrawData()

@property (nonatomic, strong) NSMutableArray* strokeData;

@end

@implementation StrokeDrawData

@synthesize numberOfPoints = _numberOfPoints;
@synthesize strokeData = _strokeData;

- (id) init
{
    self = [super init];
    if (self)
    {
        self.strokeData = [NSMutableArray arrayWithCapacity:100];
    }
    return self;
}

- (void) addDrawPoint:(CGPoint) dataPoint
{
    NSValue *point = [NSValue valueWithCGPoint: dataPoint];
    [self.strokeData addObject:point];
}

- (NSArray *) drawPoints
{
    return self.strokeData;
}

- (NSUInteger) numberOfPoints
{
    return self.strokeData.count;
}

@end
