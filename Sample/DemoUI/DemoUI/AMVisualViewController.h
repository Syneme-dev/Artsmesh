//
//  AMVisualViewController.h
//  DemoUI
//
//  Created by xujian on 6/9/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMVisualViewController : NSViewController
- (IBAction)onVisualTabClick:(NSButton *)sender;
- (IBAction)onOSCTabClick:(id)sender;
- (IBAction)onAudioTabClick:(id)sender;
- (IBAction)onVideoTabClick:(id)sender;
@property (strong) IBOutlet NSTabView *tabView;




@end
