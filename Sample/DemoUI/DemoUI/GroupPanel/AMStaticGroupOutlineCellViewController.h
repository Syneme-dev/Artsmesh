//
//  AMStaticGroupOutlineCellViewController.h
//  DemoUI
//
//  Created by 王 为 on 7/10/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMStatusNet/AMStatusNetGroupParser.h"

@interface AMStaticGroupOutlineCellViewController : NSViewController

@property AMStatusNetGroup* staticGroup;

-(void)updateUI;
-(void)setTrackArea;
-(void)removeTrackAres;

@end
