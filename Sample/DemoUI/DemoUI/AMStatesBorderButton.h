//
//  AMStatesBorderButton.h
//  UIFramework
//
//  Created by Brad Phillips on 9/5/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMTheme.h"
#import "AMStatesBorderButtonViewController.h"

@interface AMStatesBorderButton : NSView

@property (strong) AMStatesBorderButtonViewController *buttonVC;
@property (strong) AMTheme *currentTheme;

@end
