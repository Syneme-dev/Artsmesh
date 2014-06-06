//
//  AMChatViewController.h
//  DemoUI
//
//  Created by Wei Wang on 4/19/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMNetworkUtils/AMHolePunchingSocket.h"

@interface AMChatViewController : NSViewController<AMHolePunchingSocketDelegate>

@property (nonatomic) NSMutableArray *chatRecords;
@property (weak) IBOutlet NSTextField *chatMsgField;
@property (weak) IBOutlet NSTableView *tableView;

- (IBAction)sendMsg:(id)sender;

@end
