//
//  AMFloatPanelViewController.h
//  DemoUI
//
//  Created by Brad Phillips on 11/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMLiveMapView.h"
#import "AMFlippedView.h"
#import "UIFramework/BlueBackgroundView.h"


@interface AMFloatPanelViewController : NSViewController

@property (strong) IBOutlet BlueBackgroundView *panelTop;

@property (strong) IBOutlet NSButton *closeBtn;
@property (strong) IBOutlet NSButton *fullScreenBtn;

@property (strong) IBOutlet AMFlippedView *panelContent;

@property (strong) IBOutlet NSTextField *titleTextField;

@property NSString *panelTitle;
@property NSColor *panelTitleColor;
@property NSWindow *containerWindow;
//@property BOOL isClosed;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andSize:(NSSize)theSize andTitle:(NSString *)theTitle andTitleColor:(NSColor *)theTitleColor;

- (IBAction)closePanel:(id)sender;
- (IBAction)toggleFullScreen:(id)sender;

- (void)setFloatPanelTitle:(NSString *)panelTitle;


@end
