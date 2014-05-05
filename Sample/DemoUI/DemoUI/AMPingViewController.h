//
//  AMPingViewController.h
//  DemoUI
//
//  Created by 王 为 on 5/5/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMPingViewController : NSViewController<NSTableViewDelegate, NSTableViewDataSource>
@property (weak) IBOutlet NSTableView *userTable;
@property (unsafe_unretained) IBOutlet NSTextView *outputTextView;

@end
