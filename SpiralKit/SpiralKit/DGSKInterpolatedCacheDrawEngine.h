//
//  DGSKInterpolatedCacheDrawEngine.h
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

#import <UIKit/UIKit.h>

#import "DGSKDrawEngineAbstract.h"

#import "DGSKDrawEngineProtocol.h"

// This value is referenced by most cache-based draw engine subclasses
// so it is intentionally exposed in the header.
#define CACHE_MINIMUM_DRAW_POINT_THRESHOLD 0

@interface DGSKInterpolatedCacheDrawEngine : DGSKDrawEngineAbstract<DGSKDrawEngineProtocol>

@property (nonatomic) CGPoint activePoint0;
@property (nonatomic) CGPoint activePoint1;
@property (nonatomic) CGPoint activePoint2;
@property (nonatomic) CGPoint activePoint3;

@property (nonatomic) CGRect dirtyRect1;
@property (nonatomic) CGRect dirtyRect2;

- (void) performDrawWithContext:(CGContextRef)context;
- (void) establishDrawRegion:(CGPoint) point1 point2:(CGPoint) point2;

- (void) restoreViewImage: (UIImage *)viewImage toContext:(CGContextRef)context;

@end
