//
//  AMETCDPreferenceViewController.h
//  DemoUI
//
//  Created by 王 为 on 3/31/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMETCDPreferenceViewController : NSViewController
@property (retain) IBOutlet NSTabView *tabs;

- (IBAction)onETCDTabClick:(id)sender;
- (IBAction)onJackServerTabClick:(id)sender;


@end
