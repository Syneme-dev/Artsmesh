//
//  AMFloatPanelViewController.m
//  DemoUI
//
//  Created by Brad Phillips on 11/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMFloatPanelViewController.h"
#import "AMFloatPanelView.h"

@implementation AMFloatPanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
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
    if (self.containerWindow) {
        AMFloatPanelView *panelView = (AMFloatPanelView *)self.view;
        panelView.inFullScreenMode = NO;
        [self.containerWindow orderFront:self];
    }
}

@end
