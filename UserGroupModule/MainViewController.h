//
//  MainViewController.h
//  UserGroupModule
//
//  Created by xujian on 3/7/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainViewController : NSViewController <NSOutlineViewDataSource,NSOutlineViewDelegate>

@property (weak) IBOutlet NSOutlineView *userGroupTreeView;
@property (weak) IBOutlet NSTextField *createGroupNameField;
@property (strong) IBOutlet NSTreeController *userGroupTreeController;
@property NSMutableArray* groups;

- (IBAction)createNewGroup:(id)sender;
- (IBAction)deleteGroup:(id)sender;
- (IBAction)setUserName:(id)sender;



@end
