//
//  AMThemes.m
//  Artsmesh
//
//  Created by Brad Phillips on 9/5/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMTheme.h"

@implementation AMTheme

- (id) init
{
    if (self = [super init])
    {
        // TO-DO: Check for global preference on theme & instantiate theme colors based on user's selected theme (dark, light, etc)
        self.themeColors = [[NSDictionary alloc] initWithObjectsAndKeys:
                            UI_Color_gray, @"defaultBackground",
                            nil];
    }
    return self;
}

@end
