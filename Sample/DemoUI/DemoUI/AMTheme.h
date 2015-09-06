//
//  AMThemes.h
//  Artsmesh
//
//  Created by Brad Phillips on 9/5/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

// Default Dark theme color definitions
#define UI_Color_gray [NSColor colorWithCalibratedRed:0.152 green:0.152 blue:0.152 alpha:1]
#define UI_Color_b7b7b7  [NSColor colorWithCalibratedRed:(168)/255.0f green:(168)/255.0f blue:(168)/255.0f alpha:1.0f]
#define UI_Color_b7b7b7_Disable  [NSColor colorWithCalibratedRed:(84)/255.0f green:(84)/255.0f blue:(84)/255.0f alpha:1.0f]
#define UI_Color_blue [NSColor colorWithCalibratedRed:(46)/255.0f green:(58)/255.0f blue:(75)/255.0f alpha:1.0f]

@interface AMTheme : NSObject

@property (strong) NSDictionary *themeColors;

@end
