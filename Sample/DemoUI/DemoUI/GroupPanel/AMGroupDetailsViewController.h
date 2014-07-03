//
//  AMGroupDetailsViewController.h
//  DemoUI
//
//  Created by Wei Wang on 7/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMMesher/AMAppObjects.h"

@interface AMGroupDetailsViewController : NSViewController

@property AMGroup* group;

-(void)updateUI;

@end
