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

+ (AMTheme *) sharedInstance
{
    static dispatch_once_t shared_initialized;
    static AMTheme *shared_instance = nil;
    
    dispatch_once(&shared_initialized, ^ {
        shared_instance = [[AMTheme alloc] init];
    });
    
    return shared_instance;
}

- (id) init
{
    if (self = [super init])
    {
        // TO-DO: Check for global preference on theme & instantiate theme colors based on user's selected theme (dark, light, etc)
        NSString *curTheme = [[NSUserDefaults standardUserDefaults] stringForKey:@"Preference_Key_Active_Theme"];
        
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
        
        // Set default theme colors
        self.colorAlert = UI_Color_Yellow;
        self.colorError = UI_Color_Red;
        self.colorSuccess = UI_Color_Green;
        
        self.colorBackground = UI_Color_Gray;
        self.colorBackgroundAlert = UI_Color_Red;
        self.colorBackgroundError = UI_Color_Yellow;
        self.colorBackgroundSuccess = UI_Color_Green;
        self.colorBackgroundHover = UI_Color_Blue;
        
        self.colorBorder = UI_Color_Light_Grey;
        self.colorBorderAlert = UI_Color_Red;
        self.colorBorderError = UI_Color_Yellow;
        self.colorBorderSuccess = UI_Color_Green;
        
        self.colorText = UI_Color_Light_Grey;
        self.colorTextDisabled = UI_Color_Disabled;
        self.colorTextAlert = UI_Color_Red;
        self.colorTextError = UI_Color_Yellow;
        self.colorTextSuccess = UI_Color_Green;
    
        // Set default theme fonts
        self.fontHeader = [fontManager fontWithFamily:@"FoundryMonoline" traits:NSItalicFontMask weight:8 size:12.0];
        self.fontHeaderItalic = [fontManager fontWithFamily:@"FoundryMonoline" traits:NSItalicFontMask weight:8 size:12.0];
        self.fontStandard = [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:8 size:10.0];
        self.fontStandardItalic = [fontManager fontWithFamily:@"FoundryMonoline" traits:NSItalicFontMask weight:8 size:10.0];
        
        if (![curTheme isEqualToString: @"dark"]) {
            [self setTheme:curTheme];
        } else {
            [self setTheme:@"default"];
        }
    }
    return self;
}

-(void) setTheme: (NSString *)themeName {
    NSColor *newColorAlert;
    NSColor *newColorError;
    NSColor *newColorSuccess;
    
    NSColor *newColorBackground;
    NSColor *newColorBackgroundPrimary;
    NSColor *newColorBackgroundAlert;
    NSColor *newColorBackgroundError;
    NSColor *newColorBackgroundSuccess;
    NSColor *newColorBackgroundHover;
    
    NSColor *newColorBorder;
    NSColor *newColorBorderAlert;
    NSColor *newColorBorderError;
    NSColor *newColorBorderSuccess;
    
    NSColor *newColorText;
    NSColor *newColorTextAlert;
    NSColor *newColorTextError;
    NSColor *newColorTextSuccess;
    
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *newFontHeader;
    NSFont *newFontHeaderItalic;
    NSFont *newFontStandard;
    NSFont *newFontStandardItalic;
    
    
    if ( [themeName isEqualToString:@"light"] ) {
        // Configure variables to match light theme
        newColorBackground = [NSColor colorWithCalibratedRed:(221)/255.0f green:(221)/255.0f blue:(221)/255.0f alpha:1.0f];
        newColorBackgroundHover = [NSColor colorWithCalibratedRed:(60)/255.0f green:(75)/255.0f blue:(95)/255.0f alpha:1.0f];
    } else {
        // If no theme matches one called, go with default colors
        newColorAlert = UI_Color_Yellow;
        newColorError = UI_Color_Red;
        newColorSuccess = UI_Color_Green;
        
        newColorBackground = UI_Color_Gray;
        newColorBackgroundAlert = UI_Color_Yellow;
        newColorBackgroundError = UI_Color_Red;
        newColorBackgroundSuccess = UI_Color_Green;
        newColorBackgroundHover = UI_Color_Blue;
        
        newColorBorder = UI_Color_Light_Grey;
        newColorBorderAlert = UI_Color_Red;
        newColorBorderError = UI_Color_Yellow;
        newColorBorderSuccess = UI_Color_Green;
        
        newColorText = UI_Color_Light_Grey;
        newColorTextAlert = UI_Color_Yellow;
        newColorTextError = UI_Color_Red;
        newColorTextSuccess = UI_Color_Green;
        
        newFontHeader = [fontManager fontWithFamily:@"FoundryMonoline" traits:NSItalicFontMask weight:8 size:12.0];
        newFontHeaderItalic = [fontManager fontWithFamily:@"FoundryMonoline" traits:NSItalicFontMask weight:8 size:12.0];
        newFontStandard = [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:8 size:10.0];
        newFontStandardItalic = [fontManager fontWithFamily:@"FoundryMonoline" traits:NSItalicFontMask weight:8 size:10.0];
        
    }

    // Set theme colors
    self.colorAlert = newColorAlert;
    self.colorError = newColorError;
    self.colorSuccess = newColorSuccess;
    
    self.colorBackground = newColorBackground;
    self.colorBackgroundAlert = newColorBackgroundAlert;
    self.colorBackgroundError = newColorBackgroundError;
    self.colorBackgroundSuccess = newColorBackgroundSuccess;
    self.colorBackgroundHover = newColorBackgroundHover;
    
    self.colorBorder = newColorBorder;
    self.colorBorderAlert = newColorBorderAlert;
    self.colorBorderError = newColorBorderError;
    self.colorBorderSuccess = newColorBorderSuccess;
    
    self.colorText = newColorText;
    self.colorTextAlert = newColorTextAlert;
    self.colorTextError = newColorTextError;
    self.colorTextSuccess = newColorTextSuccess;
    
    // Set theme fonts
    self.fontHeader = newFontHeader;
    self.fontHeaderItalic = newFontHeaderItalic;
    self.fontStandard = newFontStandard;
    self.fontStandardItalic = newFontStandardItalic;
    
    // Shout it out to the world!
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AMThemeChanged" object:self];
}

@end
