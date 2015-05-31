//
//  DrawData.m
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

#import "DrawData.h"
#import "StrokeDrawData.h"

@interface DrawData()

@property (nonatomic, strong) NSMutableArray *strokeData;

@end

@implementation DrawData

@synthesize contentBitmap = _contentBitmap;

- (NSArray *) drawStrokes
{
    return self.strokeData;
}

- (void) strokeFinalized
{
}

- (id<DGSKStrokeDataProviderProtocol>) createStrokeInstance
{
    id<DGSKStrokeDataProviderProtocol> stroke = nil;
    stroke = [[StrokeDrawData alloc] init];
    
    return stroke;
}

- (void) addStroke:(id<DGSKStrokeDataProviderProtocol>) stroke
{
    [self.strokeData addObject:stroke];
}

@end
