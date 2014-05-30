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
#import "AMMesher/AMGroup.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMNotificationManager/AMNotificationManager.h"
#import "AMStatusNetModule/AMStatusNetModule.h"

@interface AMChatViewController ()

- (void)showChatRecord:(NSDictionary *)record;

@end

@implementation AMChatViewController
{
    GCDAsyncUdpSocket *_socket;
    AMChatHolePunchingClient* _holePunchingClient;
    BOOL _isHolePunching;
    NSData *_heartBeatData;
    AMGroup* _myGroup;
    AMUserPortMap* _charPortMap;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _chatRecords = [[NSMutableArray alloc] init];
        _isHolePunching = NO;
        _heartBeatData = [@"HB" dataUsingEncoding:NSUTF8StringEncoding];
    }
    return self;
}

-(void)awakeFromNib
{
    [[AMNotificationManager defaultShared] listenMessageType:self withTypeName:AM_USERGROUPS_CHANGED callback:@selector(userGroupsChanged:)];
    
    [self startChat];
}

-(void)startChat
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


-(void)userGroupsChanged:(NSNotification*) notification
{
    NSMutableArray* joinedUsers = nil;
    NSMutableArray* leavedUsers = nil;
    
    AMGroup* myNewGroup = notification.userInfo[@"myGroup"];
    if (_myGroup != nil) {
        joinedUsers = [[NSMutableArray alloc] init];
        leavedUsers = [[NSMutableArray alloc] init];
        for (AMUser* newUser in myNewGroup.users) {
            
            BOOL bFind = NO;
            for(AMUser* oldUser in _myGroup){
                if ([oldUser.userid isEqualToString:newUser.userid]) {
                    bFind = YES;
                    break;
                }
            }
            if (bFind == NO) {
                [joinedUsers addObject:newUser];
            }
        }
        
        for (AMUser* oldUser in _myGroup.users) {
            
            BOOL bFind = NO;
            for(AMUser* newUser in myNewGroup.users){
                if ([oldUser.userid isEqualToString:newUser.userid]) {
                    bFind = YES;
                    break;
                }
            }
            if (bFind == NO) {
                [leavedUsers addObject:oldUser];
            }
        }
    }
    
    _myGroup = myNewGroup;
    
    if (joinedUsers != nil ) {
        for (AMUser* newUser in joinedUsers) {
            NSDictionary *record = @{
                                     @"sender"  : @"SYSTEM",
                                     @"message" : [NSString stringWithFormat:@"%@ JOINED THE CONVERSATION",
                                                   newUser.nickName],
                                     @"time"    : [NSDate date]
                                     };
            [self showChatRecord:record];
        }
    }
    
    if (leavedUsers) {
        for (AMUser* user in leavedUsers) {
            NSDictionary *record = @{
                                     @"sender"  : @"SYSTEM",
                                     @"message" : [NSString stringWithFormat:@"%@ LEAVED THE CONVERSATION",
                                                   user.nickName],
                                     @"time"    : [NSDate date]
                                     };
            [self showChatRecord:record];
        }
    }
}

- (IBAction)sendMsg:(id)sender
{
    NSString* msg = [self.chatMsgField stringValue];
    if(msg == nil || [msg isEqualToString:@""]){
        return;
    }

    AMMesher* mesher = [AMMesher sharedAMMesher];
    NSString* nickName = mesher.mySelf.nickName;

    NSData *msgData = [NSKeyedArchiver archivedDataWithRootObject:
                    @{@"sender":nickName, @"message":msg, @"time":[NSDate date]}];

    if(_myGroup != nil){
        for (AMUser* user in _myGroup.users){
            NSString* ip ;
            if ([user.localLeader isEqualToString:mesher.mySelf.localLeader]){
                ip = user.privateIp;
                
            }else{
                ip = user.publicIp;
            }

            if (_isHolePunching){
                [_holePunchingClient sendPacket:msgData toHost:ip toPort:_charPortMap.natMapPort];
            }else{
                [_socket sendData:msgData toHost:ip port:[_charPortMap.internalPort intValue] withTimeout:-1 tag:0];
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
    [self handleIncomingData:data fromAddress:address];
}


-(void)handleIncomingData:(NSData*)data fromAddress:(NSData*)address
{
    if ([data isEqualToData:_heartBeatData])
        return;
    NSDictionary *chatRecord = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self showChatRecord:chatRecord];
}

@end
