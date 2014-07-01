//
//  AMUserDetailsViewController.h
//  DemoUI
//
//  Created by Wei Wang on 7/2/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMMesher/AMAppObjects.h"

@interface AMUserDetailsViewController : NSViewController

@property AMUser* user;

-(void)updateUI;

@end
