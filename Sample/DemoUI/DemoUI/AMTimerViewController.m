//
//  AMTimerViewController.m
//  DemoUI
//
//  Created by xujian on 6/26/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMTimerViewController.h"
#import "UIFramework/AMFoundryFontView.h"
#import "AMTimer/AMTimer.h"
#import <UIFramework/AMButtonHandler.h>

@interface AMTimerViewController ()
@property (weak) IBOutlet NSButton *clockBtn;
@property (weak) IBOutlet NSButton *timerBtn;
@property (weak) IBOutlet NSTabView *tabView;
@end

@implementation AMTimerViewController

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
    [super awakeFromNib];
    [self.timerBtn performClick:nil];
}

-(void)registerTabButtons{
    super.tabs=self.tabView;
    self.tabButtons =[[NSMutableArray alloc]init];
    [self.tabButtons addObject:self.clockBtn];
    [self.tabButtons addObject:self.timerBtn];
    self.showingTabsCount=2;
    [AMButtonHandler changeTabTextColor:self.clockBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.timerBtn toColor:UI_Color_blue];
}


- (IBAction)clockBtnClick:(id)sender
{
    [self pushDownButton:self.clockBtn];
    [self.tabView selectTabViewItemAtIndex:1];
}

- (IBAction)timerBtnClick:(id)sender
{
    [self pushDownButton:self.timerBtn];
    [self.tabView selectTabViewItemAtIndex:0];
}

@end
