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
#import "AMTabPanelViewController.h"
#import "UIFramework/AMBorderView.h"



#define UI_Color_gray [NSColor colorWithCalibratedRed:0.152 green:0.152 blue:0.152 alpha:1]
@interface AMPanelViewController ()
{
    NSWindow *_floatingWindow;
}

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
    [self.fullScreenButton setHidden:YES];
    [self.maxSizeButton setHidden:YES];

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
    if(self.movedFromController!=nil)
    {
        NSInteger tabIndex=[self.tabPanelViewController.tabs indexOfTabViewItem:self.tabPanelViewController.tabs.selectedTabViewItem];
        [self.movedFromController reAttachTab:tabIndex];
        
    }
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

- (IBAction)toggleFullScreen:(id)sender
{
    
}

- (IBAction)onTearClick:(id)sender {
    AMPanelView *panelView= (AMPanelView*) self.view;
    if (!panelView.tearedOff) {
        NSPoint p = [panelView convertPoint:NSMakePoint(0, panelView.bounds.size.height)
                                     toView:nil];
        NSRect rect = NSMakeRect(p.x, p.y, 0, 0);
        rect = [panelView.window convertRectToScreen:rect];
        NSPoint windowOrigin = rect.origin;
        
        [panelView removeFromSuperview];
        panelView.tearedOff = YES;
        [self.fullScreenButton setHidden:NO];
        AMBorderView *contentView = [[AMBorderView alloc] initWithView:panelView];
        
        _floatingWindow = [[NSWindow alloc] initWithContentRect:contentView.frame
                                                     styleMask:NSBorderlessWindowMask
                                                       backing:NSBackingStoreBuffered
                                                         defer:NO];
        _floatingWindow.contentView = contentView;
        _floatingWindow.level = NSFloatingWindowLevel;
        _floatingWindow.hasShadow = YES;
        _floatingWindow.backgroundColor = [NSColor colorWithCalibratedHue:0.15
                                                               saturation:0.15
                                                               brightness:0.15
                                                                    alpha:1.0];
        [_floatingWindow setFrameOrigin:windowOrigin];
        
        NSSize screenSize = panelView.window.screen.visibleFrame.size;
//        NSPoint windowOrigin;
//        windowOrigin.x = screenSize.width - panelView.frame.size.width;
//        windowOrigin.y = screenSize.height - panelView.frame.size.height;
//        [_floatingWindow.animator setFrameOrigin:windowOrigin];
        NSRect windowFrame = contentView.frame;
        windowFrame.origin.x = screenSize.width - contentView.frame.size.width;
        windowFrame.origin.y = screenSize.height - contentView.frame.size.height;
        [_floatingWindow.animator setFrame:windowFrame display:NO];
        
        [_floatingWindow makeKeyAndOrderFront:self];
    } else {
        [panelView removeFromSuperview];
        [panelView setTranslatesAutoresizingMaskIntoConstraints:YES];
        _floatingWindow = nil;
        panelView.tearedOff = NO;
        [self.fullScreenButton setHidden:YES];
        [[[NSApp delegate] mainWindowController].containerView addSubview:panelView];
        [panelView scrollRectToVisible:panelView.bounds];
    }
}

- (IBAction)onCopyTabButtonClick:(id)sender {
    if(self.tabPanelViewController ==nil)
    {
        return;
    }
     NSInteger index=[self.tabPanelViewController.tabs indexOfTabViewItem:self.tabPanelViewController.tabs.selectedTabViewItem];
    //Note:handle when there is no tab left.
    if(self.tabPanelViewController.showingTabsCount==1)
    {
        return;//Note: do not copy any more.
    }
    NSButton *button= self.tabPanelViewController.tabButtons[index];
    [button setHidden:YES];
    for (int i=0; i<self.tabPanelViewController.tabButtons.count; i++) {
        NSButton *buttonItem =self.tabPanelViewController.tabButtons[i];
        if (buttonItem.isHidden==FALSE) {
            [self.tabPanelViewController.tabs selectTabViewItemAtIndex:i];
        }
    }

    [self.tabPanelViewController.view  setNeedsDisplay:YES];
    NSString *tabPanelTitle=[NSString stringWithFormat:@"%@ - %@",self.title,button.title ];
    [[AM_APPDELEGATE mainWindowController] createTabPanelWithType:self.panelId withTitle:tabPanelTitle withTabId:button.title withTabIndex:index from:self];
    self.tabPanelViewController.showingTabsCount--;
}

-(void)reAttachTab:(NSInteger)tabIntex{
    NSButton *button= self.tabPanelViewController.tabButtons[tabIntex];
    [button setHidden:NO];
     self.tabPanelViewController.showingTabsCount++;
    [self.tabPanelViewController.tabs selectTabViewItemAtIndex:tabIntex];

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
