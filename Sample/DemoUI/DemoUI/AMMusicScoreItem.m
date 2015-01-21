//
//  AMMusicScoreItem.m
//  DemoUI
//
//  Created by whiskyzed on 1/20/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMMusicScoreItem.h"

@implementation AMMusicScoreItem
@synthesize name;
@synthesize image;

- (NSString *)name
{
    if (!name) {
        name = @"unknown";
    }
    return name;
}

//avoid nil image
- (NSImage *)image
{
    if (!image) {
        image = [NSImage imageNamed:@""];
    }
    return image;
}

@end
