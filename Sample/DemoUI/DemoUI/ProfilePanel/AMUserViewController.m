//
//  AMUserViewController.m
//  DemoUI
//
//  Created by 王 为 on 3/31/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserViewController.h"
#import <UIFramework/AMButtonHandler.h>
#import "NSView_Constrains.h"

@interface AMUserViewController ()
@end

@implementation AMUserViewController
{
    NSMutableArray *_tabControllers;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


-(void)awakeFromNib
{
    [super awakeFromNib];

    [AMButtonHandler changeTabTextColor:self.userTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.groupTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.projectTabButton toColor:UI_Color_blue];
    [self onUserTabClick:self.userTabButton];
}


-(void)registerTabButtons{
    super.tabs=self.tabs;
    self.tabButtons =[[NSMutableArray alloc]init];
    [self.tabButtons addObject:self.userTabButton];
    [self.tabButtons addObject:self.groupTabButton];
    [self.tabButtons addObject:self.projectTabButton];
    self.showingTabsCount=3;
}

- (IBAction)onUserTabClick:(id)sender
{
    [self pushDownButton:self.userTabButton];
    [self.tabs selectTabViewItemAtIndex:0];
}

- (IBAction)onGroupTabClick:(id)sender
{
    [self pushDownButton:self.groupTabButton];
    [self.tabs selectTabViewItemAtIndex:1];
}

- (IBAction)onProjectTabClick:(id)sender
{
    // Project Tab Clicked
    [self pushDownButton:self.projectTabButton];
    [self.tabs selectTabViewItemAtIndex:2];
}

-(void)viewDidLoad
{
    [self loadTabViews];
}

-(void)loadTabViews
{
    for (NSTabViewItem* tabItem in [self.tabs tabViewItems]) {
        
        /*Here we use the class name to load the controller so the
         tab identifier must equal to the tabview's subview controller's name*/
        
        if (_tabControllers == nil) {
            _tabControllers = [[NSMutableArray alloc] init];
        }
        
        NSString *tabViewControllerName = tabItem.identifier;
        id obj = [[NSClassFromString(tabViewControllerName) alloc] init];
        if ([obj isKindOfClass:[NSViewController class]]) {
            NSViewController *controller = (NSViewController *)obj;
            
            [tabItem.view addFullConstrainsToSubview:controller.view];
            [_tabControllers addObject:controller];
        }
    }
}

@end
