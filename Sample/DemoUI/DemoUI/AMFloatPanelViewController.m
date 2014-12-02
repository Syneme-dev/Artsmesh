//
//  AMFloatPanelViewController.m
//  DemoUI
//
//  Created by Brad Phillips on 11/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMFloatPanelViewController.h"

@interface AMFloatingWindow : NSWindow

@end

@interface AMFloatPanelViewController () {
    AMFloatingWindow *_floatingWindow;
}

@end

@implementation AMFloatPanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)closePanel:(id)sender {
    if (_floatingWindow) {
        _floatingWindow = nil;
    }
    self.containerWindow.isVisible = NO;
    [self.closeBtn setState:0];
}

- (IBAction)toggleFullScreen:(id)sender
{
    [_floatingWindow toggleFullScreen:self];
}

- (void)windowWillExitFullScreen:(NSNotification *)notification
{
    [_floatingWindow orderFront:self];
}

@end
