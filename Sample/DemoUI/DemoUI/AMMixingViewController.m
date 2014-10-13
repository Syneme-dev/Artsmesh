//
//  AMMixingViewController.m
//  DemoUI
//
//  Created by xujian on 6/9/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMMixingViewController.h"
#import <UIFramework/AMButtonHandler.h>


@interface AMMixingViewController ()

@end

@implementation AMMixingViewController

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
    [self.tabButtons addObject:self.outputTab];
    self.showingTabsCount=3;
    [AMButtonHandler changeTabTextColor:self.videoTab toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.audioTab toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.outputTab toColor:UI_Color_blue];

}

- (IBAction)onAudioTabClick:(id)sender {
    [self pushDownButton:self.audioTab];
    [self.tabs selectTabViewItemAtIndex:1];
}

- (IBAction)onVideoTabClick:(id)sender {
    [self pushDownButton:self.videoTab];
    [self.tabs selectTabViewItemAtIndex:0];
}

- (IBAction)onOutputTabClick:(id)sender {
    [self pushDownButton:self.outputTab];
    [self.tabs selectTabViewItemAtIndex:2];
}
@end
