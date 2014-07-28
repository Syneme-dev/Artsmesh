//
//  AMUserLogonViewController.m
//  DemoUI
//
//  Created by Wei Wang on 7/24/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserLogonViewController.h"
#import "UIFramework/AMButtonHandler.h"

@interface AMUserLogonViewController ()
@property (weak) IBOutlet NSButton *loginBtn;
@property (weak) IBOutlet NSButton *registerBtn;

@end

@implementation AMUserLogonViewController

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
    [AMButtonHandler changeTabTextColor:self.loginBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.registerBtn toColor:UI_Color_blue];
}

@end
