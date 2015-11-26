//
//  AMVisualViewController.m
//  DemoUI
//
//  Created by xujian on 6/9/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMVisualViewController.h"
#import "AMAudio/AMAudio.h"
#import <UIFramework/AMButtonHandler.h>
#import "AMOSCGroups/AMOSCGroups.h"
#import "AMRouteViewController.h"


@interface AMVisualViewController ()
@property (weak) IBOutlet NSTabView*    tabView;
@property (weak) IBOutlet NSButton*     audioTab;
@property (weak) IBOutlet NSButton*     videoTab;
- (IBAction)onAudioTabClick:(id)sender;
- (IBAction)onVideoTabClick:(id)sender;

@property (nonatomic) NSMutableArray *viewControllers;
@end

@implementation AMVisualViewController
{
    NSViewController* _audioRouterVC;
    NSViewController* _videoRouterVC;
}


-(void)awakeFromNib
{
    [super awakeFromNib];
    [AMButtonHandler changeTabTextColor:self.audioTab toColor:UI_Color_b7b7b7];
 //   [AMButtonHandler changeTabTextColor:self.videoTab toColor:UI_Color_b7b7b7];

    [self loadAudioRouterView];
    [self loadVideoRouterView];
   // [self registerTabButtons];
   
    [self pushDownButton:self.audioTab];
}

-(void)loadTabViews
{

}

-(void)registerTabButtons{
    super.tabs=self.tabs;
    self.tabButtons =[[NSMutableArray alloc]init];
    [self.tabButtons addObject:self.videoTab];
    [self.tabButtons addObject:self.audioTab];
    self.showingTabsCount=2;
    [AMButtonHandler changeTabTextColor:self.videoTab toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.audioTab toColor:UI_Color_blue];
    [self onAudioTabClick:self.audioTab];
}

- (IBAction)onAudioTabClick:(id)sender {
    [self pushDownButton:self.audioTab];
    [self.tabs selectTabViewItemAtIndex:0];
}

- (IBAction)onVideoTabClick:(id)sender {
    [self pushDownButton:self.videoTab];
    [self.tabs selectTabViewItemAtIndex:1];
}


-(void)loadAudioRouterView
{
    _audioRouterVC = [[AMAudio sharedInstance] getJackRouterUI];
    if (_audioRouterVC) {
        NSView* contentView = _audioRouterVC.view;
        contentView.frame = NSMakeRect(0, 0, 800, 600);
        
        NSView *superView = [self.tabView tabViewItemAtIndex:self.viewControllers.count].view;
        [superView addSubview:contentView];
        [self.viewControllers addObject:_audioRouterVC];
        
        
        [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSDictionary *views = NSDictionaryOfVariableBindings(contentView);
        [superView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[contentView]-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [superView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[contentView]-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
    }
}


-(void)loadVideoRouterView
{
    _videoRouterVC = [[AMRouteViewController alloc]
                            initWithNibName:@"AMRouteViewController"
                                     bundle:nil];
    
    if (_videoRouterVC) {
        NSView* contentView = _videoRouterVC.view;
        contentView.frame = NSMakeRect(0, 0, 800, 600);
        
        NSView *superView = [self.tabView tabViewItemAtIndex:self.viewControllers.count].view;
        [superView addSubview:contentView];
        [self.viewControllers addObject:_videoRouterVC];
        
        
        [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSDictionary *views = NSDictionaryOfVariableBindings(contentView);
        [superView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[contentView]-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [superView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[contentView]-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
    }
}


- (NSMutableArray *)viewControllers
{
    if (!_viewControllers) {
        _viewControllers = [NSMutableArray array];
    }
    return _viewControllers;
}

@end
