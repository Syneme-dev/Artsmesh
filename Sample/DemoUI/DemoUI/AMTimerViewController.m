//
//  AMTimerViewController.m
//  DemoUI
//
//  Created by xujian on 6/26/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMTimerViewController.h"
#import "UIFramework/AMFoundryFontView.h"
//#import "AMTimer/AMTimer.h"
#import <UIFramework/AMButtonHandler.h>
#import "AMTimerTabVC.h"
#import "AMClockTabVC.h"

@interface AMTimerViewController ()
@property (weak) IBOutlet NSButton *addNewOne;
@property (weak) IBOutlet NSButton *clockBtn;
@property (weak) IBOutlet NSButton *timerBtn;
@property (weak) IBOutlet NSTabView *tabView;
@property (nonatomic) NSMutableArray *viewControllers;
@property (nonatomic) NSInteger         index;
@end

@implementation AMTimerViewController

-(void)awakeFromNib
{
    [self addViewController:[AMClockTabVC class]
                    fromNib:@"AMClockTabVC"
                     bundle:nil];
    
    [self addViewController:[AMTimerTabVC class]
                    fromNib:@"AMTimerTabVC"
                     bundle:nil];
    
    
    
    [AMButtonHandler changeTabTextColor:self.clockBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.timerBtn toColor:UI_Color_blue];

    [AMButtonHandler changeTabTextColor:self.addNewOne toColor:UI_Color_blue];
    
    [self registerTabButtons];

    [self.clockBtn performClick:nil];
    [self.addNewOne performClick:nil];
    [self.timerBtn performClick:nil];
    
}

-(void)registerTabButtons{
    super.tabs=self.tabView;
    self.tabButtons =[[NSMutableArray alloc]init];
    [self.tabButtons addObject:self.clockBtn];
    [self.tabButtons addObject:self.timerBtn];
    self.showingTabsCount=2;
}

- (void)addViewController:(Class)aViewControllerClass
                  fromNib:(NSString *)nibName
                   bundle:(NSBundle *)bundle
{
    NSViewController *vc = [[aViewControllerClass alloc] initWithNibName:nibName bundle:bundle];
    NSView* contentView = vc.view;
    NSView *superView = [self.tabView tabViewItemAtIndex:self.viewControllers.count].view;
    [superView addSubview:contentView];
    [self.viewControllers addObject:vc];
    
    [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(contentView);
    [superView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentView]-0-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    [superView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentView]-0-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
}

- (NSMutableArray *)viewControllers
{
    if (!_viewControllers) {
        _viewControllers = [NSMutableArray array];
    }
    return _viewControllers;
}

- (IBAction)clockBtnClick:(id)sender
{
    _index = 0;
    [self pushDownButton:self.clockBtn];
    [self.tabView selectTabViewItemAtIndex:_index];
}

- (IBAction)timerBtnClick:(id)sender
{
    _index = 1;
    [self pushDownButton:self.timerBtn];
    [self.tabView selectTabViewItemAtIndex:_index];
}
- (IBAction)addNewTableCell:(id)sender {
    if (_index == 0) {
        AMClockTabVC* clockVC = [_viewControllers objectAtIndex:_index];
        [clockVC addTableCell:nil];
    }
    else if(_index == 1){
        AMTimerTabVC* timerVC = [_viewControllers objectAtIndex:_index];
        [timerVC addTableCellController:nil];
    }
    
}

@end
