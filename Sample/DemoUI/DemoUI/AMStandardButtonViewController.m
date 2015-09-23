//
//  AMStatesBorderButtonViewController.m
//  UIFramework
//
//  Created by Brad Phillips on 9/5/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMStandardButtonViewController.h"

@interface AMStandardButtonViewController ()

@end

@implementation AMStandardButtonViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        self.currentTheme = [[AMTheme alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    NSColor *buttonColor = [self.currentTheme.themeColors objectForKey:@"background"];
    
    [self.contentView changeBackgroundColor:buttonColor];

}

- (void)viewWillAppear {
    [super viewWillAppear];
}

@end
