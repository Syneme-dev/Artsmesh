//
//  AMGroupDetailsViewController.h
//  DemoUI
//
//  Created by Wei Wang on 7/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMCoreData/AMCoreData.h"
#import "AMGroupDetailViewDelegate.h"

@interface AMGroupDetailsViewController : NSViewController

@property id<AMGroupDetailViewDelegate> hostVC;
@property AMLiveGroup* group;

-(void)updateUI;

@end
