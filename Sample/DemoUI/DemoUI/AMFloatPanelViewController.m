//
//  AMFloatPanelViewController.m
//  DemoUI
//
//  Created by Brad Phillips on 11/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMFloatPanelViewController.h"

@interface AMFloatPanelViewController ()

@end

@implementation AMFloatPanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)closePanel:(id)sender {
    self.containerWindow.isVisible = NO;
    [self.closeBtn setState:0];
}

@end
