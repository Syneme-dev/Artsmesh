//
//  AMGroupOutlineUserCellController.h
//  AMGroupOutlineTest
//
//  Created by 王 为 on 6/27/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMMesher/AMAppObjects.h"

@interface AMGroupOutlineUserCellController : NSViewController

@property AMGroup* group;
@property AMUser* user;
@property BOOL editable;


-(void)updateUI;
-(void)setTrackArea;
-(void)removeTrackAres;

@end
