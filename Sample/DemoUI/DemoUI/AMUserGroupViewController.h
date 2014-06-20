//
//  AMUserGroupViewController.h
//  DemoUI
//
//  Created by Wei Wang on 4/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMUserGroupViewController : NSViewController<NSOutlineViewDelegate, NSOutlineViewDataSource>

@property (weak) IBOutlet NSTextField *createGroupTextField;
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSView *groupCellView;
@property (weak) IBOutlet NSButton *groupCellViewJoinBtn;
@property NSArray* userGroups;

-(void)doubleClickOutlineView:(id)sender;
- (IBAction)unmerge:(id)sender;
- (IBAction)createGroupByEnter:(id)sender;


@end
