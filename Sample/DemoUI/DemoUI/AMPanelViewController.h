//
//  AMPanelViewController.h
//  DemoUI
//
//  Created by xujian on 3/6/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMPanelViewController : NSViewController

@property (strong) IBOutlet NSView *toolBarView;

@property (weak) IBOutlet NSTextField *titleView;
- (IBAction)closePanel:(id)sender;

-(void)setTitle:(NSString *)title;

@end
