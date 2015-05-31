//
//  DGSKGraphicsUtils.m
//  SpiralKit by Digital Generalists
//
//  Created by Mark Johnson on 11/25/12.
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

#import "DGSKGraphicsUtils.h"

#import "SpiralKitTypes.h"

@implementation DGSKGraphicsUtils

+ (UIColor *) colorFromRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
    return [DGSKGraphicsUtils colorFromRed:red green:green blue:blue alpha:1.0];
}

+ (UIColor *) colorFromRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {(red/255.0), (green/255.0), (blue/255.0), alpha};
    CGColorRef color = CGColorCreate(colorspace, components);
    
    UIColor *colorObject = [UIColor colorWithCGColor:color];

    
    CGColorRelease(color);
    CGColorSpaceRelease(colorspace);
    
    return colorObject;
}

@end
