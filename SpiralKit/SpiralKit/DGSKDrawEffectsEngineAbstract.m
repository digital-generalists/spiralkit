//
//  DGSKDrawEffectsEngineAbstract.m
//  SpiralKit by Digital Generalists
//
//  Created by Mark Johnson on 8/20/12.
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

#import "DGSKDrawEffectsEngineAbstract.h"

@interface DGSKDrawEffectsEngineAbstract()

@end

@implementation DGSKDrawEffectsEngineAbstract

- (id) init
{
    self = [super init];
    if (self)
    {
        // Because of the circular nature of the relationship between the effects engine
        // and the styling provider, we are intentionally not loading the styling
        // provider as part of the initialization of the effects engine.
        // NOTE:  Consumers of the effects engine assume responsibility for setting the styling
        // provider.
        // NOTE:  All effects engine classes must assume that the styling provider can be set
        // and or changed at any time.  Doing so, they should effectly reset the state of the
        // effects engine.
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    
}

- (id) initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self)
    {
        
    }
    return self;
}

@end
