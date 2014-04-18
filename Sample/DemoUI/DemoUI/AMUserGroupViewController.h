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

@property (weak) IBOutlet NSTextField *createGroupTextField;
@property (weak) IBOutlet NSOutlineView *userGroupOutline;
@property (strong) IBOutlet NSTreeController *treeViewController;
@property (weak) AMMesher* sharedMesher;

- (IBAction)joinGroup:(id)sender;
- (IBAction)createGroup:(id)sender;
- (IBAction)quitGroup:(id)sender;
- (IBAction)createGroupByEnter:(id)sender;

@end
