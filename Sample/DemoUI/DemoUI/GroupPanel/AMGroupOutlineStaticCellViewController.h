//
//  AMGroupOutlineStaticCellViewController.h
//  DemoUI
//
//  Created by Wei Wang on 7/19/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMCoreData/AMCoreData.h"

@interface AMGroupOutlineStaticCellViewController : NSViewController

@property AMStaticGroup* staticGroup;
@property AMStaticUser* staticUser;
@property NSMutableArray* userControllers;

-(void)setTrackArea;
-(void)removeTrackAres;
-(void)updateUI;

@end
