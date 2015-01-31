//
//  AMUserDetailsViewController.h
//  DemoUI
//
//  Created by Wei Wang on 7/2/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMCoreData/AMCoreData.h"
#import "AMGroupDetailViewDelegate.h"

@interface AMUserDetailsViewController : NSViewController

@property id<AMGroupDetailViewDelegate> hostVC;
@property AMLiveUser* user;

-(void)updateUI;

@end
