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
#import "UIFramework/AMTheme.h"

@interface AMFloatingWindow : NSWindow

@end

@implementation AMFloatingWindow

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

@end


#define UI_Color_gray [NSColor colorWithCalibratedRed:0.152 green:0.152 blue:0.152 alpha:1]
@interface AMPanelViewController ()
{
    AMFloatingWindow *_floatingWindow;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeTheme:)
                                                 name:@"AMThemeChanged"
                                               object:nil];
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
    //Now:callback delegate for notification.
    if([self.amActionDelegate respondsToSelector:@selector(closeAction)]){
        [self.amActionDelegate closeAction];
    }

    
    
    self.contentPanelViewController=nil;
    if(self.movedFromController!=nil)
    {
        NSInteger tabIndex=[self.tabPanelViewController.tabs indexOfTabViewItem:self.tabPanelViewController.tabs.selectedTabViewItem];
        [self.movedFromController reAttachTab:tabIndex];
        
    }
    [self.view removeFromSuperview];
    if (_floatingWindow)
        _floatingWindow.isVisible = NO;
        _floatingWindow = nil;
//    [self.view setHidden:YES];
    AMAppDelegate *appDelegate=[NSApp delegate];
    NSString *sideItemId=[[self.panelId mutableCopy]stringByReplacingOccurrencesOfString:@"_PANEL" withString:@""];
    [appDelegate.mainWindowController setSideBarItemStatus:sideItemId withStatus:NO ];
//    NSMutableArray *openedPanels=[(NSMutableArray*)[[AMPreferenceManager standardUserDefaults] objectForKey:UserData_Key_OpenedPanel] mutableCopy];

//    [openedPanels  removeObject:self.panelId];
//    [[AMPreferenceManager standardUserDefaults] setObject:openedPanels forKey:UserData_Key_OpenedPanel];
    
    if([appDelegate.mainWindowController.panelControllers.allKeys containsObject:self.panelId])
    {
        [appDelegate.mainWindowController.panelControllers removeObjectForKey:self.panelId ];
    }
    
    //Note:move right panel to left when close.
}

- (IBAction)toggleFullScreen:(id)sender
{
    [_floatingWindow toggleFullScreen:self];
}

- (NSSize)window:(NSWindow *)window willUseFullScreenContentSize:(NSSize)proposedSize
{
    return proposedSize;
}

- (void)windowWillEnterFullScreen:(NSNotification *)notification
{
    [self.tearOffButton setHidden:YES];
    self.closeButton.hidden = YES;
    AMPanelView *panelView = (AMPanelView *)self.view;
    panelView.inFullScreenMode = YES;
}

- (void)windowDidExitFullScreen:(NSNotification *)notification
{
    [self.tearOffButton setHidden:NO];
    self.closeButton.hidden = NO;
    AMPanelView *panelView = (AMPanelView *)self.view;
    panelView.inFullScreenMode = NO;
    [_floatingWindow orderFront:self];
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
        
        _floatingWindow = [[AMFloatingWindow alloc] initWithContentRect:contentView.frame
                                                     styleMask:NSBorderlessWindowMask
                                                       backing:NSBackingStoreBuffered
                                                         defer:NO];
        _floatingWindow.contentView = contentView;
        _floatingWindow.level = NSFloatingWindowLevel;
        _floatingWindow.hasShadow = YES;
//        _floatingWindow.backgroundColor = [NSColor colorWithCalibratedHue:0.15
//                                                               saturation:0.15
//                                                               brightness:0.15
//                                                                    alpha:1.0];
//        [_floatingWindow setOpaque:NO];
//        _floatingWindow.backgroundColor = [NSColor clearColor];
        _floatingWindow.collectionBehavior |= NSWindowCollectionBehaviorFullScreenPrimary;
        _floatingWindow.delegate = self;
        [_floatingWindow setFrameOrigin:windowOrigin];
        
        NSSize screenSize = panelView.window.screen.frame.size;
//        NSPoint windowOrigin;
//        windowOrigin.x = screenSize.width - panelView.frame.size.width;
//        windowOrigin.y = screenSize.height - panelView.frame.size.height;
//        [_floatingWindow.animator setFrameOrigin:windowOrigin];
        NSRect windowFrame = contentView.frame;
        windowFrame.origin.x = (screenSize.width - windowFrame.size.width) / 2;
        windowFrame.origin.y = screenSize.height - windowFrame.size.height - 80;
        [_floatingWindow.animator setFrame:windowFrame display:NO];
        
        [_floatingWindow makeKeyAndOrderFront:self];
    } else {
//        [panelView removeFromSuperview];
//        [panelView setTranslatesAutoresizingMaskIntoConstraints:YES];
//        _floatingWindow = nil;
//        panelView.tearedOff = NO;
//        [self.fullScreenButton setHidden:YES];
//        [[[NSApp delegate] mainWindowController].containerView addSubview:panelView];
//        [panelView scrollRectToVisible:panelView.bounds];
        
        AMBoxItem *dummy = [[AMBoxItem alloc] initWithFrame:panelView.frame];
        [[(AMAppDelegate *)[NSApp delegate] mainWindowController].containerView addSubview:dummy];
        [dummy scrollRectToVisible:dummy.bounds];
        NSRect rectInScreen = [dummy convertRect:dummy.bounds toView:nil];
        rectInScreen = [dummy.window convertRectToScreen:rectInScreen];
        
        [_floatingWindow.animator setFrame:rectInScreen display:NO animate:YES];
        [dummy removeFromSuperview];
        [panelView removeFromSuperview];
        [panelView setTranslatesAutoresizingMaskIntoConstraints:YES];
        _floatingWindow = nil;
        panelView.tearedOff = NO;
        [self.fullScreenButton setHidden:YES];
        [[(AMAppDelegate *)[NSApp delegate] mainWindowController].containerView addSubview:panelView];
        [panelView scrollRectToVisible:panelView.enclosingRect];
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
        if (buttonItem.isHidden==NO) {
            [self.tabPanelViewController.tabs selectTabViewItemAtIndex:i];
        }
    }

    [self.tabPanelViewController.view  setNeedsDisplay:YES];
    NSString *tabPanelTitle=[NSString stringWithFormat:@"%@ - %@",self.title,button.title ];
    
    NSString *tabPanelID=[NSString stringWithFormat:@"%@_%@_TABPANEL",self.panelId,button.title ];
    [[AM_APPDELEGATE mainWindowController] createTabPanelWithType:self.panelId withTitle:tabPanelTitle withPanelId:tabPanelID withTabIndex:index from:self];
    self.tabPanelViewController.showingTabsCount--;
}

-(void)reAttachTab:(NSInteger)tabIntex{
    NSButton *button= self.tabPanelViewController.tabButtons[tabIntex];
    [button setHidden:NO];
     self.tabPanelViewController.showingTabsCount++;
    [self.tabPanelViewController.tabs selectTabViewItemAtIndex:tabIntex];

}

-(void)showAsTabPanel:(NSString*)tabTitle withTabIndex:(NSInteger)tabIndex  {
    [self.tearOffButton setHidden:NO];
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

- (void) changeTheme:(NSNotification *) notification {
    [self.view setNeedsDisplay:YES];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
