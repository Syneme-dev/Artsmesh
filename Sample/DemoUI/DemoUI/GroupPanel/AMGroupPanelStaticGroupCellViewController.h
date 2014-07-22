//
//  AMGroupPanelStaticGroupCellViewController.h
//  DemoUI
//
//  Created by Wei Wang on 7/19/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMCoreData/AMCoreData.h"
#import "AMGroupPanelTableCellViewController.h"

@interface AMGroupPanelStaticGroupCellViewController : AMGroupPanelTableCellViewController

@property AMStaticGroup* staticGroup;
@property AMStaticUser* staticUser;

@end
