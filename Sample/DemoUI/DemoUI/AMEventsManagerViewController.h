//
//  AMEventsManagerViewController.h
//  Artsmesh
//
//  Created by Brad Phillips on 5/7/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMEventsManagerViewController : NSViewController

@property (strong) IBOutlet NSTextField *feedbackTitleTextField;
@property (strong) IBOutlet NSScrollView *eventsListScrollView;

- (void)setTitle:(NSString *)title;

@end
