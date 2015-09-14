//
//  AMFloatPanelViewController.m
//  DemoUI
//
//  Created by Brad Phillips on 11/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMFloatPanelViewController.h"
#import "AMFloatPanelView.h"

#import "AMAppDelegate.h"
#import <AMPreferenceManager/AMPreferenceManager.h>
#import "AMTabPanelViewController.h"
#import "UIFramework/AMBorderView.h"

@implementation AMFloatPanelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andSize:(NSSize)theSize andTitle:(NSString *)theTitle andTitleColor:(NSColor *) theTitleColor
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.        
        self.panelTitle = theTitle;
        self.panelTitleColor = theTitleColor;
                
        // Set up the float panel view and window that will hold it
        AMFloatPanelView *floatPanel = (AMFloatPanelView *) self.view;
        [self.view setFrameSize:NSMakeSize(theSize.width, theSize.height+floatPanel.borderThickness)];
        floatPanel.initialSize = NSMakeSize(theSize.width, theSize.height+floatPanel.borderThickness);
        floatPanel.floatPanelViewController = self;
        
        floatPanel.minSizeConstraint = NSMakeSize(theSize.width, theSize.height);
        
        NSRect frame = NSMakeRect(0, 0, theSize.width, theSize.height + 21 + floatPanel.borderThickness);
        
        self.containerWindow = [[NSWindow alloc] initWithContentRect:frame
                                                           styleMask:NSBorderlessWindowMask
                                                             backing:NSBackingStoreBuffered
                                                               defer:NO];
        self.containerWindow.hasShadow = YES;
        
        [self.containerWindow setFrameOrigin:NSMakePoint((([[(AMAppDelegate *)[NSApp delegate] mainWindowController].containerView window].frame.size.width/2) - (self.containerWindow.frame.size.width/2) ), ([(AMAppDelegate *)[NSApp delegate] mainWindowController].containerView.frame.size.height/2) )];
        
        //NSLog(@"Application window dimensions: %f, %f", [[(AMAppDelegate *)[NSApp delegate] mainWindowController].containerView window].frame.size.width, [(AMAppDelegate *)[NSApp delegate] mainWindowController].containerView.frame.size.height);
        
        [self.containerWindow.contentView addSubview:floatPanel];
    
        self.view.translatesAutoresizingMaskIntoConstraints = NO;
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subView]|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:@{@"subView" : self.view}];
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subView]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:@{@"subView" : self.view}];
        [self.containerWindow.contentView addConstraints:verticalConstraints];
        [self.containerWindow.contentView addConstraints:horizontalConstraints];
        
        [self.containerWindow.contentView setAutoresizesSubviews:YES];
        [self.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        self.containerWindow.collectionBehavior |= NSWindowCollectionBehaviorFullScreenPrimary;
        self.containerWindow.delegate = (id)self;
    }
    return self;
}

- (IBAction)closePanel:(id)sender {
    self.containerWindow.isVisible = NO;
    [self.closeBtn setState:0];
}


- (IBAction)toggleFullScreen:(id)sender
{
    if (self.containerWindow) {
        [ [self.view window] toggleFullScreen:self];
    }
}

- (NSSize)window:(NSWindow *)window willUseFullScreenContentSize:(NSSize)proposedSize
{
    return proposedSize;
}

- (void)windowWillEnterFullScreen:(NSNotification *)notification
{
    if (self.containerWindow) {
        AMFloatPanelView *panelView = (AMFloatPanelView *)self.view;
        panelView.inFullScreenMode = YES;
    }
}
    
- (void)windowWillExitFullScreen:(NSNotification *)notification
{
    // Window will exit full screen.
    if (self.containerWindow) {
        AMFloatPanelView *panelView = (AMFloatPanelView *)self.view;
        panelView.inFullScreenMode = NO;
        [self.containerWindow orderFront:self];
    }
}

- (void)setFloatPanelTitle:(NSString *)panelTitle {
    self.panelTitle = panelTitle;
    [self.titleTextField setStringValue:panelTitle];
    
    [self.view setNeedsDisplay:YES];
}

@end
