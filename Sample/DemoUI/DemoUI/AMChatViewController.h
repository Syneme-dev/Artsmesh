//
//  AMChatViewController.h
//  DemoUI
//
//  Created by Wei Wang on 4/19/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMNetworkUtils/GCDAsyncUdpSocket.h"

@interface AMChatViewController : NSViewController <GCDAsyncUdpSocketDelegate>

@property (weak) IBOutlet NSTextField *chatMsgField;
@property (unsafe_unretained) IBOutlet NSTextView *msgHistory;

- (IBAction)sendMsg:(id)sender;

@end
