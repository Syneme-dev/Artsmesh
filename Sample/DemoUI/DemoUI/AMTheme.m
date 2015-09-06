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
                            UI_Color_Gray, @"background",
                            UI_Color_Light_Grey, @"textDefault",
                            UI_Color_Yellow, @"alert",
                            UI_Color_Red, @"warning",
                            UI_Color_Blue, @"hoverDefault",
                            nil];
        
        NSFontManager *fontManager = [NSFontManager sharedFontManager];
        self.themeFonts = [[NSDictionary alloc] initWithObjectsAndKeys:
                      [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:8 size:12.0], @"header",
                      [fontManager fontWithFamily:@"FoundryMonoline" traits:NSItalicFontMask weight:8 size:12.0], @"header-italic",
                      [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:8 size:10.0], @"standard",
                      [fontManager fontWithFamily:@"FoundryMonoline" traits:NSItalicFontMask weight:8 size:10.0], @"standard-italic",
                      nil];
    }
    return self;
}

@end
