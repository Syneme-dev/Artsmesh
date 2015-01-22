//
//  AMStaticUserDetailsViewController.h
//  DemoUI
//
//  Created by Wei Wang on 7/22/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AMCoreData/AMCoreData.h>
#import "AMGroupDetailViewDelegate.h"

@interface AMStaticUserDetailsViewController : NSViewController

@property (weak)id<AMGroupDetailViewDelegate> hostVC;
@property AMStaticUser* staticUser;

@end
