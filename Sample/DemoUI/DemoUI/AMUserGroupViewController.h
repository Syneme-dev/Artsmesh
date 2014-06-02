//
//  AMUserGroupViewController.h
//  DemoUI
//
//  Created by Wei Wang on 4/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AMUserGroupNode;

@interface AMUserGroupViewController : NSViewController<NSOutlineViewDelegate>
@property NSArray* userGroupNodes;
@property (weak) IBOutlet NSTextField *createGroupTextField;
@property (weak) IBOutlet NSOutlineView *userGroupOutline;
@property (strong) IBOutlet NSTreeController *treeViewController;


- (IBAction)joinGroup:(id)sender;
- (IBAction)createGroup:(id)sender;
- (IBAction)quitGroup:(id)sender;
- (IBAction)createGroupByEnter:(id)sender;


@end
