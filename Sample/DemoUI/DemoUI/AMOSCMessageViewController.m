//
//  AMOSCMessageViewController.m
//  DemoUI
//
//  Created by xujian on 6/25/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMOSCMessageViewController.h"
#import "AMOSCGroups/AMOSCGroups.h"

@interface AMOSCMessageViewController ()

@end

@implementation AMOSCMessageViewController
{
    NSViewController* _controller;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib
{
    _controller = [[AMOSCGroups sharedInstance] getOSCMonitorUI];
    if (_controller != nil) {
        
        [self.view addSubview:_controller.view];
        NSRect rect = self.view.bounds;
        
        rect.size.height -= 21;
        _controller.view.frame = rect;
    }
}

@end
