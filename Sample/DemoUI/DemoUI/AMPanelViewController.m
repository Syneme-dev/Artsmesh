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
    if (!panelView.tearedOff) {
        NSPoint p = [panelView convertPoint:NSMakePoint(0, panelView.bounds.size.height)
                                     toView:nil];
        NSRect rect = NSMakeRect(p.x, p.y, 0, 0);
        rect = [panelView.window convertRectToScreen:rect];
        NSPoint windowOrigin = rect.origin;
        
        [panelView removeFromSuperview];
        panelView.tearedOff = YES;
        panelView.frame = NSMakeRect(0, 0, panelView.initialSize.width,
                                     panelView.initialSize.height);
        
        _floatingWindow = [[NSWindow alloc] initWithContentRect:panelView.frame
                                                     styleMask:NSBorderlessWindowMask
                                                       backing:NSBackingStoreBuffered
                                                         defer:NO];
        _floatingWindow.contentView = panelView;
        _floatingWindow.level = NSFloatingWindowLevel;
        [_floatingWindow setFrameOrigin:windowOrigin];
        
        NSSize screenSize = panelView.window.screen.visibleFrame.size;
//        NSPoint windowOrigin;
//        windowOrigin.x = screenSize.width - panelView.frame.size.width;
//        windowOrigin.y = screenSize.height - panelView.frame.size.height;
//        [_floatingWindow.animator setFrameOrigin:windowOrigin];
        NSRect windowFrame = panelView.frame;
        windowFrame.origin.x = screenSize.width - panelView.frame.size.width;
        windowFrame.origin.y = screenSize.height - panelView.frame.size.height;
        [_floatingWindow.animator setFrame:windowFrame display:NO];
        
        [_floatingWindow makeKeyAndOrderFront:self];
    } else {
        _floatingWindow = nil;
        AMMainWindowController *mainWindowController = [[NSApp delegate] mainWindowController];
        panelView.tearedOff = NO;
        [mainWindowController.containerView addSubview:panelView];
        [panelView scrollRectToVisible:panelView.bounds];
    }
}
@end
