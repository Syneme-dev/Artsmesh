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
#import "AMTimerTabVC.h"

@interface AMTimerViewController ()
@property (weak) IBOutlet NSButton *clockBtn;
@property (weak) IBOutlet NSButton *timerBtn;
@property (weak) IBOutlet NSTabView *tabView;
@property (nonatomic) NSMutableArray *viewControllers;
@end

@implementation AMTimerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _viewControllers = [NSMutableArray array];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self addViewControllerFromNib:@"AMTimerTabVC" bundle:nil];
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

- (void)addViewControllerFromNib:(NSString *)nibName bundle:(NSBundle *)bundle
{
    NSViewController *vc = [[NSViewController alloc] initWithNibName:nibName bundle:bundle];
    NSView* contentView = vc.view;
    [self.tabView addSubview:contentView];
    
    [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(contentView);
    [self.tabView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentView]-0-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    [self.tabView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentView]-0-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
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
