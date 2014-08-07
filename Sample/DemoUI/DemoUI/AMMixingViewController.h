//
//  AMMixingViewController.h
//  DemoUI
//
//  Created by xujian on 6/9/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMTabPanelViewController.h"
#import <UIFramework/AMBlueButton.h>

@interface AMMixingViewController : AMTabPanelViewController
@property (strong) IBOutlet AMBlueButton *audioTab;
@property (strong) IBOutlet AMBlueButton *videoTab;
@property (strong) IBOutlet AMBlueButton *outputTab;
- (IBAction)onAudioTabClick:(id)sender;
- (IBAction)onVideoTabClick:(id)sender;
- (IBAction)onOutputTabClick:(id)sender;
@property (strong) IBOutlet NSTabView *tabs;

@end
