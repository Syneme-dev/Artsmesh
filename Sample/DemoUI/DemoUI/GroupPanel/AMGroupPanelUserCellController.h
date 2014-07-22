//
//  AMGroupPanelUserCellController.h
//  AMGroupOutlineTest
//
//  Created by 王 为 on 6/27/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMCoreData/AMCoreData.h"
#import "AMGroupPanelTableCellController.h"

@interface AMGroupPanelUserCellController : AMGroupPanelTableCellController

@property AMLiveGroup* group;
@property AMLiveUser* user;
@property BOOL localUser;

@end
