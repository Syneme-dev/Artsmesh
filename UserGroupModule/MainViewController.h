//
//  MainViewController.h
//  UserGroupModule
//
//  Created by xujian on 3/7/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainViewController : NSViewController <NSOutlineViewDataSource,NSOutlineViewDelegate>
@property (weak) IBOutlet NSOutlineView *userGroupTree;
@property (weak) IBOutlet NSTextField *clusterLeader;

@end
