//
//  AMStatesBorderButtonViewController.h
//  UIFramework
//
//  Created by Brad Phillips on 9/5/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMFlippedView.h"
#import "UIFramework/AMTheme.h"

@interface AMStandardButtonViewController : NSViewController

@property (strong) AMTheme *currentTheme;
@property (strong) IBOutlet AMFlippedView *borderView;
@property (strong) IBOutlet AMFlippedView *contentView;
@property (strong) IBOutlet NSTextField *buttonTitleTextField;

@end
