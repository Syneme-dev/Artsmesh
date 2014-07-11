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

- (IBAction)onCopyTabButtonClick:(id)sender {
    //TOOD:Create a new panel
     NSInteger index=[self.tabPanelViewController.tabs indexOfTabViewItem:self.tabPanelViewController.tabs.selectedTabViewItem];
    if(self.tabPanelViewController.showingTabsCount==1)
    {
        return;//Note: do not copy any more.
    }
     NSButton *button= self.tabPanelViewController.tabButtons[index];
//
    
    
    //TODO:handle when there is no tab left.
    
    [button setHidden:YES];
    for (int i=0; i<self.tabPanelViewController.tabButtons.count; i++) {
        NSButton *buttonItem =self.tabPanelViewController.tabButtons[i];
        if (buttonItem.isHidden==FALSE) {
            [self.tabPanelViewController.tabs selectTabViewItemAtIndex:i];
        }
    }

    [self.tabPanelViewController.view  setNeedsDisplay:YES];
    NSString *tabPanelTitle=[NSString stringWithFormat:@"%@ - %@",self.title,button.title ];
     [[AM_APPDELEGATE mainWindowController] createPanelWithType:self.panelId withTitle:tabPanelTitle isTab:YES withTabId:button.title withTabIndex:index ];
    self.tabPanelViewController.showingTabsCount--;
}

-(void)showAsTabPanel:(NSString*)tabTitle withTabIndex:(NSInteger)tabIndex  {
    [self.tearOffButton setHidden:YES];
    [self.settingButton setHidden:YES];
    [self.tabPanelButton setHidden:YES];
    [self.maxSizeButton setHidden:YES];
    [self.fullScreenButton setHidden:YES];
    [self setTitle:tabTitle];
    for (int i=0; i<[self.tabPanelViewController.tabButtons count]; i++) {
        [self.tabPanelViewController.tabButtons[i] setHidden:YES];
    }
     [self.view setNeedsDisplay:YES];
    [self.tabPanelViewController selectTabIndex:tabIndex];
}
@end
