//
//  AMLiveMapProgramViewController.m
//  DemoUI
//
//  Created by Brad Phillips on 10/28/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMLiveMapProgramViewController.h"
#import "AMMesher/AMMesher.h"
#import "AMLiveMapProgramView.h"
#import "UIFramework/AMButtonHandler.h"

#define UI_Color_gray [NSColor colorWithCalibratedRed:0.152 green:0.152 blue:0.152 alpha:1]

@interface AMLiveMapProgramViewController ()

@end

@implementation AMLiveMapProgramViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andGroup:(AMLiveGroup *)theGroup
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //NSLog(@"live map program view initiated!");
        // Initialization code here.
        NSImage *broadcastIcon = [NSImage imageNamed:@"group_broadcast"];
        self.liveIcon.image = broadcastIcon;
        //NSLog(@"live icon is %@", self.liveIcon.image);
    }
    return self;
}

-(void)awakeFromNib
{
    
}

-(void)checkIcon:(AMLiveGroup *)theGroup {
    if (theGroup.broadcasting && [theGroup.broadcastingURL length] != 0) {
        NSImage *broadcastIcon = [NSImage imageNamed:@"group_broadcast_med"];
        self.liveIcon.image = broadcastIcon;
    } else {
        NSImage *clipIcon = [NSImage imageNamed:@"clipboard"];
        self.liveIcon.image = clipIcon;
    }
}


@end
