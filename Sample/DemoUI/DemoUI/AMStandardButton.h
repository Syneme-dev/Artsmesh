//
//  AMStatesBorderButton.h
//  UIFramework
//
//  Created by Brad Phillips on 9/5/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMTheme.h"
#import "AMStandardButtonViewController.h"

@interface AMStandardButton : NSView

@property (strong) AMStandardButtonViewController *buttonVC;
@property (strong) AMTheme *currentTheme;
@property (strong) NSArray *states;
@property (strong) NSString *type;
@property BOOL triggerPressed;
@property BOOL isPressing;
@property BOOL isHovering;

- (void)setButtonTitle:(NSString *)buttonTitle;
- (void)changeState:(NSString *)theState;
- (void)setDisabledStateWithText:(NSString *)theText;
- (void)setActiveStateWithText:(NSString *)theText;
- (void)setAlertStateWithText:(NSString *)theText;
- (void)setErrorStateWithText:(NSString *)theText andResetText:(NSString *)theResetText;
- (void)setSuccessStateWithText:(NSString *)theText andResetText:(NSString *)theResetText;

@end
