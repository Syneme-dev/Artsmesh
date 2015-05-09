//
//  AMEventsManagerRowViewController.h
//  Artsmesh
//
//  Created by Brad Phillips on 5/8/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UIFramework/AMCheckBoxView.h"

@interface AMEventsManagerRowViewController : NSViewController

@property (strong) IBOutlet NSTextField *eventTitleTextView;
@property (strong) IBOutlet AMCheckBoxView *eventEditCheckBox;
@property (strong) IBOutlet AMCheckBoxView *eventDeleteCheckBox;

@end
