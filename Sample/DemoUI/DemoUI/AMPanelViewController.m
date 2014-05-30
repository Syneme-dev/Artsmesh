//
//  AMPanelViewController.m
//  DemoUI
//
//  Created by xujian on 3/6/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMPanelViewController.h"
#import "AMAppDelegate.h"
#import "UIFramework/AMPanelView.h"
@interface AMPanelViewController ()

@end

@implementation AMPanelViewController


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
     [self.titleView setFont: [NSFont fontWithName: @"FoundryMonoline-Medium" size: self.titleView.font.pointSize]];
}

-(void)setTitle:(NSString *)title{
    [self.titleView setStringValue:title];
}

- (IBAction)closePanel:(id)sender {
    [self.view setHidden:YES];
    AMAppDelegate *appDelegate=[NSApp delegate];
    [appDelegate.mainWindowController setSideBarItemStatus:self.titleView.stringValue withStatus:NO ];
    //Note:move right panel to left when close.
}
- (IBAction)onTearClick:(id)sender {
    AMPanelView *panelView= (AMPanelView*) self.view;
    panelView.backgroundColor = [NSColor colorWithCalibratedRed:(38)/255.0f green:(38)/255.0f blue:(38)/255.0f alpha:1.0f];
    [panelView setNeedsDisplay:YES];
}
@end
