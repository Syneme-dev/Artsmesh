//
//  AMUserGroupViewController.h
//  DemoUI
//
//  Created by Wei Wang on 4/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AMMesher;

@interface AMUserGroupViewController : NSViewController<NSOutlineViewDelegate>

@property (weak) IBOutlet NSOutlineView *userGroupOutline;
@property (strong) IBOutlet NSTreeController *treeViewController;
@property (weak) IBOutlet NSButton *onlineButton;
@property (weak) IBOutlet NSButton *joinGroupButton;
@property (weak) AMMesher* sharedMesher;
@property (weak) IBOutlet NSTextField *createGroupName;

- (IBAction)goOnline:(id)sender;
- (IBAction)joinGroup:(id)sender;
- (IBAction)createGroup:(id)sender;
- (IBAction)quitGroup:(id)sender;

@end
