//
//  AMVisualViewController.m
//  DemoUI
//
//  Created by xujian on 6/9/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMVisualViewController.h"

@interface AMVisualViewController ()

@end

@implementation AMVisualViewController

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
@end
