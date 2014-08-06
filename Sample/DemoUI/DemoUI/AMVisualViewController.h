//
//  AMVisualViewController.h
//  DemoUI
//
//  Created by xujian on 6/9/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <UIFramework/AMBlueButton.h>
#import "AMTabPanelViewController.h"

@interface AMVisualViewController : AMTabPanelViewController
- (IBAction)onVisualTabClick:(NSButton *)sender;
- (IBAction)onOSCTabClick:(id)sender;
- (IBAction)onAudioTabClick:(id)sender;
- (IBAction)onVideoTabClick:(id)sender;
@property (strong) IBOutlet NSTabView *tabView;
@property (strong) IBOutlet AMBlueButton *oscTab;
@property (strong) IBOutlet AMBlueButton *visualTab;

@property (strong) IBOutlet AMBlueButton *videoTab;

@property (strong) IBOutlet AMBlueButton *audioTab;


@end
