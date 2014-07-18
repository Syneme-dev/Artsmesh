//
//  AMGroupOutlineGroupCellController.h
//  AMGroupOutlineTest
//
//  Created by 王 为 on 6/27/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMCoreData/AMCoreData.h"

@interface AMGroupOutlineGroupCellController : NSViewController

@property AMLiveGroup* group;
@property NSMutableArray* userControllers;
@property BOOL editable;

-(void)setTrackArea;
-(void)removeTrackAres;
-(void)updateUI;

@end
