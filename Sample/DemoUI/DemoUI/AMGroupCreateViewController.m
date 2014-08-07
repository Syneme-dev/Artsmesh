//
//  AMGroupCreateViewController.m
//  DemoUI
//
//  Created by Wei Wang on 8/5/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupCreateViewController.h"
#import "UIFramework/AMButtonHandler.h"

@interface AMGroupCreateViewController ()
@property (weak) IBOutlet NSButton *createBtn;

@end

@implementation AMGroupCreateViewController

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
    [AMButtonHandler changeTabTextColor:self.createBtn toColor:UI_Color_blue];
}

@end
