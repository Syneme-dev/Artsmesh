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
    
    [self.eventDeleteCheckBox setDelegate:(id)self];
    [self.eventDeleteCheckBox setFontSize:10.0];
    self.eventDeleteCheckBox.title = @"";
}

@end
