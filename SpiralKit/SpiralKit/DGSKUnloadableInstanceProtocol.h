//
//  DGSKUnloadableInstanceProtocol.h
//  SpiralKit by Digital Generalists
//
//  Created by Mark Johnson on 12/19/13.
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

@protocol DGSKUnloadableInstanceProtocol <NSObject>

// NOTE:  This is a convience method for clearing the retained-state of an object in the draw engine.  The mechanism
// enables the release of allocated objects on the framework object hierarchy.  It should play nicely with an alternate
// memory-cleanup strategy.  If you want to largely ignore it and come up with a better/alternate cleanup mechanism,
// that's okay.
- (void) prepareForUnload;

@end
