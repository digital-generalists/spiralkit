//
//  DGSKDrawContextStylingProvider.h
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

#import <SpiralKitTypes.h>

@protocol DGSKDrawEffectsEngineProtocol;
@protocol DGSKDrawContextStylingProviderProtocol;

@interface DGSKDrawContextStylingProviderAbstract : NSObject<NSCoding>

@property (nonatomic) DGSKDrawToolType drawToolType;

@property (nonatomic) UIColor *color;

@property (nonatomic) CGBlendMode blendMode;

@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) CGLineCap lineStyle;

@property (nonatomic, strong) id<DGSKDrawEffectsEngineProtocol>effectsEngine;

- (id) init;
- (id) initAsToolType:(DGSKDrawToolType)type;
- (id) initWithStylingProvider:(id<DGSKDrawContextStylingProviderProtocol>)provider;

- (bool) applyPropertiesToContext:(CGContextRef)context;
- (bool) applyPropertiesToContext:(CGContextRef)context withEffectsBasedOnPoints:(NSArray *)points;
- (void) resetEffects;

- (void) applyToolType:(DGSKDrawToolType)toolType;

@end
