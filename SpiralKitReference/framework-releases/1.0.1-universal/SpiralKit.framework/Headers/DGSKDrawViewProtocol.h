//
//  DGSKDrawViewProtocol.h
//  SpiralKit by Digital Generalists
//
//  Created by Mark Johnson on 7/19/13.
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

#import <Foundation/Foundation.h>

#import <DGSKUnloadableInstanceProtocol.h>

@protocol DGSKDrawEngineProtocol;

@protocol DGSKDrawViewProtocol <DGSKUnloadableInstanceProtocol>

@property (strong, nonatomic) id<DGSKDrawEngineProtocol> drawEngine;

@end
