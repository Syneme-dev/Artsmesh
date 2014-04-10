//
//  AMUserGroupViewController.h
//  DemoUI
//
//  Created by Wei Wang on 4/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AMMesher;

@interface AMUserGroupViewController : NSViewController

@property (weak) IBOutlet NSOutlineView *userGroupOutline;

@property (strong) IBOutlet NSTreeController *treeViewController;

@property (weak) AMMesher* sharedMesher;


@end
