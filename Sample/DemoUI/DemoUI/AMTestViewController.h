//
//  AMTestViewController.h
//  DemoUI
//
//  Created by xujian on 6/5/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMTestViewController : NSViewController
@property (strong) IBOutlet NSPopUpButton *popUpButton;
- (IBAction)ShowUserButtonClick:(id)sender;
@property (strong) IBOutlet NSTextField *groupNameText;
- (IBAction)ShowGroupButtonClick:(id)sender;

@end
