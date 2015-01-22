//
//  AMStaticGroupDetailsViewController.h
//  DemoUI
//
//  Created by Wei Wang on 7/11/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMCoreData/AMCoreData.h"
#import "AMGroupDetailViewDelegate.h"


@interface AMStaticGroupDetailsViewController : NSViewController

@property AMStaticGroup* staticGroup;
@property (weak)id<AMGroupDetailViewDelegate> hostVC;

@end
