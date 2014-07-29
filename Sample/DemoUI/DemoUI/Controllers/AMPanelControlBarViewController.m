//
//  AMPanelControlBarViewController.m
//  DemoUI
//
//  Created by xujian on 7/23/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMPanelControlBarViewController.h"
#import "AMAppDelegate.h"

@interface AMPanelControlBarViewController ()

@end

@implementation AMPanelControlBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (IBAction)onSidebarItemClick:(NSButton *)sender {

    AMAppDelegate *appDelegate=AM_APPDELEGATE;
    NSString *panelId=
    [[NSString stringWithFormat:@"%@_PANEL",sender.identifier ] uppercaseString];
    if(sender.state==NSOnState)
    {
        [appDelegate.mainWindowController createPanelWithType:panelId withId:panelId];
    }
    else
    {
        [appDelegate.mainWindowController  removePanel:panelId];
    }
}

@end
