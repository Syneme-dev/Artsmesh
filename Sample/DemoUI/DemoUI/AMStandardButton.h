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

@interface AMStandardButton : NSView

@property (strong) AMStatesBorderButtonViewController *buttonVC;
@property (strong) AMTheme *currentTheme;
@property (strong) NSArray *states;
@property (strong) NSString *type;

- (void)setButtonTitle:(NSString *)buttonTitle;
- (void)changeState:(NSString *)theState;

@end
