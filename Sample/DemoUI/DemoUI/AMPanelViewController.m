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
#import <AMPreferenceManager/AMPreferenceManager.h>



#define UI_Color_gray [NSColor colorWithCalibratedRed:0.152 green:0.152 blue:0.152 alpha:1]
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

- (NSString *)title
{
    return self.titleView.stringValue;
}
//-()

- (IBAction)closePanel:(id)sender {
    [self.view removeFromSuperview];
//    [self.view setHidden:YES];
    AMAppDelegate *appDelegate=[NSApp delegate];
    NSString *sideItemId=[[self.panelId mutableCopy]stringByReplacingOccurrencesOfString:@"_PANEL" withString:@""];
    [appDelegate.mainWindowController setSideBarItemStatus:sideItemId withStatus:NO ];
    NSMutableArray *openedPanels=[(NSMutableArray*)[[AMPreferenceManager instance] objectForKey:UserData_Key_OpenedPanel] mutableCopy];

    [openedPanels  removeObject:self.panelId];
    [[AMPreferenceManager instance] setObject:openedPanels forKey:UserData_Key_OpenedPanel];
    
    if([appDelegate.mainWindowController.panelControllers.allKeys containsObject:self.panelId])
    {
        [appDelegate.mainWindowController.panelControllers removeObjectForKey:self.panelId ];
    }
    //Note:move right panel to left when close.
}
- (IBAction)onTearClick:(id)sender {
    AMPanelView *panelView= (AMPanelView*) self.view;
    panelView.backgroundColor = UI_Color_gray;
    [panelView setNeedsDisplay:YES];
}
@end
