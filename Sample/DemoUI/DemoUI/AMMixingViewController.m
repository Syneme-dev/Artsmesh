//
//  AMMixingViewController.m
//  DemoUI
//
//  Created by xujian on 6/9/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMMixingViewController.h"
#import <UIFramework/AMButtonHandler.h>
#import "AMAudio/AMAudio.h"
#import "AMVideo.h"
#import "AMVideoMixerViewController.h"

@interface AMMixingViewController ()

@end

@implementation AMMixingViewController
{
     NSViewController* _audioMixerViewController;
     AMVideoMixerViewController* _videoMixerViewController;
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
    super.tabs=self.tabs;
    self.tabButtons =[[NSMutableArray alloc]init];
    [self.tabButtons addObject:self.videoTab];
    [self.tabButtons addObject:self.audioTab];
    self.showingTabsCount=2;
    [AMButtonHandler changeTabTextColor:self.videoTab toColor:UI_Color_blue];
    [self onVideoTabClick:self.videoTab];
}

- (IBAction)onAudioTabClick:(id)sender {
    [self pushDownButton:self.audioTab];
    [self.tabs selectTabViewItemAtIndex:1];
}

- (IBAction)onVideoTabClick:(id)sender {
    [self pushDownButton:self.videoTab];
    [self.tabs selectTabViewItemAtIndex:0];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self loadTabViews];
    [AMButtonHandler changeTabTextColor:self.videoTab toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.audioTab toColor:UI_Color_blue];
    
    [self pushDownButton:self.audioTab];
    [self pushDownButton:self.videoTab];
}

-(void)viewWillDisappear
{
//    [_videoMixerViewController.syphonClientsManager stopAll];
}

-(void)loadTabViews
{
    NSArray* tabItems = [self.tabs tabViewItems];
    
    for (NSTabViewItem* item in tabItems) {
        NSView* view = item.view;
        if ([view.identifier isEqualTo:@"Audio Mixer"]) {
            [self loadAudioMixerView: view];
        } else if ([view.identifier isEqualTo:@"Video Mixer"]) {
            [self loadVideoMixerView:view];
        }
    }
}

-(void)loadAudioMixerView:(NSView*)tabView
{
    _audioMixerViewController = [[AMAudio sharedInstance] getMixerUI];
    if (_audioMixerViewController) {
        NSView* contentView = _audioMixerViewController.view;
        //contentView.frame = NSMakeRect(0, 0, 800, 600);
        [tabView addSubview:contentView];
        
        [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSDictionary *views = NSDictionaryOfVariableBindings(contentView);
        [tabView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentView]-0-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        
        [tabView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentView]-0-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
    }
}

-(void)loadVideoMixerView:(NSView*)tabView
{
    _videoMixerViewController = (AMVideoMixerViewController*)[[AMVideo sharedInstance] getMixerUI];
    if (_videoMixerViewController) {
        NSView* contentView = _videoMixerViewController.view;
        //contentView.frame = NSMakeRect(0, 0, 800, 600);
        [tabView addSubview:contentView];
        
        [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSDictionary *views = NSDictionaryOfVariableBindings(contentView);
        [tabView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentView]-0-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [tabView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentView]-0-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
     
    }
}

@end
