//
//  SpiralKit.h
//  SpiralKit by Digital Generalists
//
//  Created by Mark Johnson on 4/23/15.
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

#import "SpiralKitTypes.h"

#import "DGSKDrawEngineProtocol.h"
#import "DGSKBezierCurveInterpolatedCacheDrawEngine.h"
#import "DGSKQuadCurveInterpolatedCacheDrawEngine.h"
#import "DGSKDouglasPeuckerStrokeDrawEngine.h"
#import "DGSKSingleStrokeCacheDrawEngine.h"

#import "DGSKDrawContextStylingProviderProtocol.h"
#import "DGSKRGBDrawContextStylingProviderProtocol.h"
#import "DGSKRGBDrawContextStylingProvider.h"

#import "DGSKDrawEffectsEngineProtocol.h"
#import "DGSKVariableWidthDrawEffectsEngine.h"
#import "DGSKEraserDrawEffectsEngine.h"
#import "DGSKHighlighterDrawEffectsEngine.h"

#import "DGSKDataProviderProtocol.h"
#import "DGSKDrawDataProviderProtocol.h"
#import "DGSKCacheDrawDataProviderProtocol.h"
#import "DGSKStrokeDataProviderProtocol.h"
#import "DGSKStrokeDrawDataProviderProtocol.h"

#import "DGSKDrawViewProtocol.h"
#import "DGSKDrawView.h"

#import "DGSKDrawEngineFactory.h"
#import "DGSKDrawContextStylingProviderFactory.h"

@interface SpiralKit : NSObject

@end
