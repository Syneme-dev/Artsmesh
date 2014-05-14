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
#import "AMNotificationManager/AMNotificationManager.h"
#import "AMStatusNetModule/AMStatusNetModule.h"
#import "AMMesher/AMHolePunchingClient.h"

@interface AMChatViewController ()

- (void)showChatRecord:(NSDictionary *)record;

@end

@implementation AMChatViewController
{
    GCDAsyncUdpSocket *_socket;
    AMChatHolePunchingClient* _holePunchingClient;
    BOOL _isHolePunching;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _chatRecords = [[NSMutableArray alloc] init];
        _isHolePunching = NO;
    }
    return self;
}

-(void)awakeFromNib
{
    AMMesher* mesher = [AMMesher sharedAMMesher];
    [mesher addObserver:self
             forKeyPath:@"isOnline"
                options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                context:nil];
    
    [[AMNotificationManager defaultShared] listenMessageType:self withTypeName:AMN_NEW_USER_JOINED callback:@selector(NewUserJoined:)];
    
    if (mesher.isOnline == NO)
    {
        [self startChatWithoutHolePunching];
    }
    else
    {
        [self startHolePunching];
    }

}

-(void)startChatWithoutHolePunching
{
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

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (![keyPath isEqualToString:@"isOnline"])
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
        return;
    }
    
    BOOL isOnlineOld = [[change objectForKey:@"old"] boolValue];
    BOOL isOnline = [[change objectForKey:@"new"] boolValue];
    if (isOnline == YES && isOnlineOld == NO)
    {
        //start hole punching
    }
    else if(isOnlineOld == YES && isOnline == NO)
    {
        //stop hole punching
    }
}

-(void)startHolePunching
{
    if (_isHolePunching == YES)
    {
        return;
    }
    
    if (_socket)
    {
        [_socket close];
        _socket = nil;
    }
    
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* hpsIp = [defaults stringForKey:Preference_Key_General_ChatStunServerIp];
    NSString* hpsPort = [defaults stringForKey:Preference_Key_General_ChatStunServerPort];
    NSString* chatPort = [defaults stringForKey:Preference_Key_General_ChatPort];
    
    _holePunchingClient = [[AMChatHolePunchingClient alloc] initWithPort:chatPort server:hpsIp serverPort:hpsPort];
    _holePunchingClient.msgDelegate = self;
    [_holePunchingClient startHolePunching];
    
    _isHolePunching = YES;
}

-(void)stopHolePunching
{
    [_holePunchingClient stopHolePunching];
    [self startChatWithoutHolePunching];
}

-(void)NewUserJoined:(NSNotification*) notification
{
    NSLog(@"new user joined");
    NSDictionary *record = @{
        @"sender"  : @"SYSTEM",
        @"message" : [NSString stringWithFormat:@"%@ JOINED THE CONVERSATION",
                      notification.userInfo[@"username"]],
        @"time"    : notification.userInfo[@"time"]
    };
    [self showChatRecord:record];
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
    
    AMMesher* mesher = [AMMesher sharedAMMesher];
    NSArray* users = mesher.myGroupUsers;
    if(users != nil)
    {
        for (AMUser* user in users)
        {
            NSString* ip ;
            if ([user.location isEqualToString:mesher.mySelf.location] &&
                [user.domain isEqualToString:mesher.mySelf.domain])
            {
                ip = user.privateIp;
            }
            else
            {
                ip = user.publicIp;
            }

            if (_isHolePunching)
            {
                [_holePunchingClient sendPacket:msgData toHost:ip toPort:user.chatPortMap];
            }
            else
            {
                [_socket sendData:msgData toHost:ip port:[user.chatPort intValue] withTimeout:-1 tag:0];
            }
        }
    }
    
    self.chatMsgField.stringValue = @"";

}

- (void)showChatRecord:(NSDictionary *)record
{
    [self willChangeValueForKey:@"chatRecords"];
    [self.chatRecords addObject:record];
    [self didChangeValueForKey:@"chatRecords"];
    [self.tableView scrollToEndOfDocument:self];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSDictionary *chatRecord = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self showChatRecord:chatRecord];
}


-(void)handleIncomingData:(NSData*)data fromAddress:(NSData*)address
{
    NSDictionary *chatRecord = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self showChatRecord:chatRecord];
}

@end
