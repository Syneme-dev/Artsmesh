//
//  AMGPlusViewController.m
//  DemoUI
//
//  Created by Wei Wang on 8/11/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGPlusViewController.h"
#import "UIFramework/AMButtonHandler.h"

@interface AMGPlusViewController ()
@property (weak) IBOutlet NSButton *cancelBtn;
@property (weak) IBOutlet NSButton *goBtn;

@end

@implementation AMGPlusViewController

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
    [AMButtonHandler changeTabTextColor:self.cancelBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.goBtn toColor:UI_Color_blue];
}

@end
