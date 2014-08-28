//
//  AMVisualViewController.m
//  DemoUI
//
//  Created by xujian on 6/9/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMVisualViewController.h"
#import "AMAudio/AMAudio.h"

@interface AMVisualViewController ()

@end

@implementation AMVisualViewController
{
    NSViewController* _audioRouterViewController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}
-(void)registerTabButtons{
    super.tabs=self.tabView;
    self.tabButtons =[[NSMutableArray alloc]init];
    [self.tabButtons addObject:self.visualTab];
    [self.tabButtons addObject:self.oscTab];
    [self.tabButtons addObject:self.audioTab];
    [self.tabButtons addObject:self.videoTab];
    self.showingTabsCount=4;
    
}

- (IBAction)onVisualTabClick:(NSButton *)sender {
    [self.tabView selectTabViewItemAtIndex:0];
}

- (IBAction)onOSCTabClick:(id)sender {
    [self.tabView selectTabViewItemAtIndex:1];
}

- (IBAction)onAudioTabClick:(id)sender {
    [self.tabView selectTabViewItemAtIndex:2];
}

- (IBAction)onVideoTabClick:(id)sender {
    [self.tabView selectTabViewItemAtIndex:3];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self loadTabViews];
}

-(void)loadTabViews
{
    NSArray* tabItems = [self.tabs tabViewItems];
    
    for (NSTabViewItem* item in tabItems) {
        NSView* view = item.view;
        if ([view.identifier isEqualTo:@"Audio Router"]) {
            [self loadAudioRouterView: view];
        }
    }
}


-(void)loadAudioRouterView:(NSView*)tabView
{
    _audioRouterViewController = [[AMAudio sharedInstance] getJackRouterUI];
    if (_audioRouterViewController) {
        NSView* contentView = _audioRouterViewController.view;
        [tabView addSubview:contentView];
        
        [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSDictionary *views = NSDictionaryOfVariableBindings(contentView);
        [tabView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[contentView]-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [tabView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[contentView]-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];

    }
}

@end
