//
//  AMStatesBorderButtonViewController.m
//  UIFramework
//
//  Created by Brad Phillips on 9/5/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMStatesBorderButtonViewController.h"

@interface AMStatesBorderButtonViewController ()

@end

@implementation AMStatesBorderButtonViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self.contentView changeBackgroundColor:[NSColor redColor]];

}

- (void)viewWillAppear {
    [super viewWillAppear];
}

@end
