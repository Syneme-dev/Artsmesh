//
//  AMEventsManagerRowViewController.m
//  Artsmesh
//
//  Created by Brad Phillips on 5/8/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMEventsManagerRowViewController.h"

@interface AMEventsManagerRowViewController ()

@end

@implementation AMEventsManagerRowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self.eventEditCheckBox setDelegate:(id)self];
    [self.eventEditCheckBox setFontSize:10.0];
    self.eventEditCheckBox.title = @"EDIT";
    
    [self.eventDeleteCheckBox setDelegate:(id)self];
    [self.eventDeleteCheckBox setFontSize:10.0];
    self.eventDeleteCheckBox.title = @"DELETE";
}

@end
