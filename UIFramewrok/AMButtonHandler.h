//
//  AMButtonHandler.h
//  UIFramewrok
//
//  Created by xujian on 4/22/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UI_Color_b7b7b7  [NSColor colorWithCalibratedRed:(168)/255.0f green:(168)/255.0f blue:(168)/255.0f alpha:1.0f]

#define UI_Color_blue [NSColor colorWithCalibratedRed:(46)/255.0f green:(58)/255.0f blue:(75)/255.0f alpha:1.0f]


@interface AMButtonHandler : NSObject


+(void)changeTabTextColor:(NSButton*) button toColor:(NSColor*)color;

@end
