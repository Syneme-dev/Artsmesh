//
//  AMThemes.h
//  Artsmesh
//
//  Created by Brad Phillips on 9/5/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

// Default Dark theme color definitions
#define UI_Color_Gray [NSColor colorWithCalibratedRed:0.152 green:0.152 blue:0.152 alpha:1]
#define UI_Color_Light_Grey  [NSColor colorWithCalibratedRed:(168)/255.0f green:(168)/255.0f blue:(168)/255.0f alpha:1.0f]
#define UI_Color_Grey_Primary [NSColor colorWithCalibratedRed:(51)/255.0f green:(51)/255.0f blue:(51)/255.0f alpha:1.0f]
#define UI_Color_Disabled  [NSColor colorWithCalibratedRed:(84)/255.0f green:(84)/255.0f blue:(84)/255.0f alpha:1.0f]
#define UI_Color_Blue [NSColor colorWithCalibratedRed:(46)/255.0f green:(58)/255.0f blue:(75)/255.0f alpha:1.0f]
#define UI_Color_Red [NSColor colorWithCalibratedRed:(255)/255.0f green:(0)/255.0f blue:(0)/255.0f alpha:1.0f]
#define UI_Color_Yellow [NSColor colorWithCalibratedRed:(255)/255.0f green:(255)/255.0f blue:(0)/255.0f alpha:1.0f]
#define UI_Color_Green [NSColor colorWithCalibratedRed:(0)/255.0f green:(255)/255.0f blue:(0)/255.0f alpha:1.0f]

@interface AMTheme : NSObject

@property (strong) NSDictionary *themeFonts;
@property (strong) NSDictionary *themeColors;

// Color Properties
@property (strong) NSColor *colorAlert;
@property (strong) NSColor *colorError;
@property (strong) NSColor *colorSuccess;

@property (strong) NSColor *colorText;
@property (strong) NSColor *colorTextDisabled;
@property (strong) NSColor *colorTextAlert;
@property (strong) NSColor *colorTextError;
@property (strong) NSColor *colorTextSuccess;

@property (strong) NSColor *colorBorder;
@property (strong) NSColor *colorBorderAlert;
@property (strong) NSColor *colorBorderError;
@property (strong) NSColor *colorBorderSuccess;

@property (strong) NSColor *colorBackground;
@property (strong) NSColor *colorBackgroundAlert;
@property (strong) NSColor *colorBackgroundError;
@property (strong) NSColor *colorBackgroundSuccess;
@property (strong) NSColor *colorBackgroundHover;


// Font Properties
@property (strong) NSFont *fontStandard;
@property (strong) NSFont *fontStandardItalic;

@property (strong) NSFont *fontHeader;
@property (strong) NSFont *fontHeaderItalic;


// Methods
+ (AMTheme *) sharedInstance;
-(void) setTheme: (NSString *)themeName;

@end
