//
//  AMChatViewController.m
//  DemoUI
//
//  Created by Wei Wang on 4/19/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMChatViewController.h"
#import "AMMesher/AMMesher.h"
#import "AMMesher/AMUser.h"
#import "AMPreferenceManager/AMPreferenceManager.h"


@implementation AMChatViewController
{
    GCDAsyncUdpSocket *_socket;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _chatRecords = [[NSMutableArray alloc] init];
        /*
        [_chatRecords addObject: @{@"sender": @"Gao MIng", @"message" : @"hello, everyone", @"time" : @"10:28 PM"}];
        [_chatRecords addObject: @{@"sender": @"Gao MIng", @"message" : @"hello, everyone", @"time" : @"10:28 PM"}];
        [_chatRecords addObject: @{@"sender": @"Gao MIng", @"message" : @"hello, everyone", @"time" : @"10:28 PM"}];
         */
        
        
        _socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                delegateQueue:dispatch_get_main_queue()];
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* chatPort =[defaults stringForKey:Preference_Key_General_ChatPort];
        int port = [chatPort intValue];
        
        NSError *error = nil;
        if (![_socket bindToPort:port error:&error]) {
            NSLog(@"Error binding: %@", error);
        }
        
        if (![_socket beginReceiving:&error]) {
            NSLog(@"Error receiving: %@", error);
        }
    }
    return self;
}

- (IBAction)sendMsg:(id)sender
{
    NSString* msg = [self.chatMsgField stringValue];
    if(msg == nil || [msg isEqualToString:@""])
    {
        return;
    }
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* nickName =[defaults stringForKey:Preference_Key_User_NickName];
    
    NSData *msgData = [NSKeyedArchiver archivedDataWithRootObject:
                    @{@"sender":nickName, @"message":msg, @"time":[NSDate date]}];
    
//    NSData* msgData = [[NSString stringWithFormat:@"%@:%@", nickName, msg] dataUsingEncoding:NSUTF8StringEncoding];
    
    AMMesher* mesher = [AMMesher sharedAMMesher];
    NSArray* users = mesher.myGroupUsers;
    if(users != nil)
    {
        for (AMUser* user in users)
        {
            NSString* ip = user.publicIp;
            int port = [user.chatPort intValue];
            
            [_socket sendData:msgData toHost:ip port:port withTimeout:-1 tag:0];
        }
    }
    
    self.chatMsgField.stringValue = @"";
    

}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSDictionary *chatRecord = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self willChangeValueForKey:@"chatRecords"];
    [self.chatRecords addObject:chatRecord];
    [self didChangeValueForKey:@"chatRecords"];
    [self.tableView scrollToEndOfDocument:self];
}
@end
