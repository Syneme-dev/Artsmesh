//
//  MainViewController.h
//  UserGroupModule
//
//  Created by xujian on 3/7/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMUserGroupClientDelegate.h"
#import "AMUserGroupServerDelegate.h"

@class AMUser;

@interface MainViewController : NSViewController <AMUserGroupClientDelegate, AMUserGroupServerDelegate>

@property (weak) IBOutlet NSOutlineView *userGroupTreeView;
@property (weak) IBOutlet NSTextField *createGroupNameField;
@property (strong) IBOutlet NSTreeController *userGroupTreeController;

@property NSMutableArray* outlineUserNodes;

- (IBAction)setUserName:(id)sender;
- (IBAction)joinGroup:(id)sender;

-(void)StopEverything;

@end
