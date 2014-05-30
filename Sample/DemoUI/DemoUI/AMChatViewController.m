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
#import "AMNetworkUtils/AMHolePunchingSocket.h"

@interface AMChatViewController ()

- (void)showChatRecord:(NSDictionary *)record;

@end

@implementation AMChatViewController
{
    AMHolePunchingSocket *_socket;
    AMGroup* _myGroup;
    AMUserPortMap* _charPortMap;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _chatRecords = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)awakeFromNib
{
    [[AMNotificationManager defaultShared] listenMessageType:self
                                                withTypeName:AM_USERGROUPS_CHANGED
                                                    callback:@selector(userGroupsChanged:)];
     [[AMNotificationManager defaultShared] listenMessageType:self
                                                 withTypeName:AM_MESHER_ONLINE
                                                     callback:@selector(onlineStatusChanged:)];
    
    
    //TODO: get preferenc
    _socket = [[AMHolePunchingSocket alloc] initWithServer: @"127.0.0.1" serverPort:@"12345" clientPort:@"9930"];
}

-(void)onlineStatusChanged:(NSNotification*) notification
{
    BOOL isOnline = [notification.userInfo[@"isOnline"] boolValue];
    if (isOnline == YES) {
        [_socket startHolePunching];
    }else{
        [_socket stopHolePunching];
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
            for(AMUser* oldUser in _myGroup.users){
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
        [self performSelectorOnMainThread:@selector(showNewCommers:) withObject:joinedUsers waitUntilDone:NO];
    }
    
    if (leavedUsers != nil) {
        [self performSelectorOnMainThread:@selector(showLeavedUsers:) withObject:leavedUsers waitUntilDone:NO];
    }
    
}

-(void)showNewCommers:(id)newCommers
{
    for (AMUser* newUser in newCommers) {
        NSDictionary *record = @{
                                 @"sender"  : @"SYSTEM",
                                 @"message" : [NSString stringWithFormat:@"%@ JOINED THE CONVERSATION",
                                               newUser.nickName],
                                 @"time"    : [NSDate date]
                                 };
        [self showChatRecord:record];
    }
}


-(void)showLeavedUsers:(id)leavedUsers
{
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


-(void)updatePortInfo
{
    NSMutableArray* peerAddrs = [[NSMutableArray alloc]  init];
    
    AMMesher* mesher = [AMMesher sharedAMMesher];
    NSString* myLocalLeaderName = mesher.mySelf.localLeader;
    
    for (AMUser* user in _myGroup.users) {
        for (AMUserPortMap* pm in user.portMaps) {
            //statements
        }
        
        
//        AMHolePunchingPeer* peerAddr = [[AMHolePunchingPeer alloc] init];
//        if ([user.localLeader isEqualToString:myLocalLeaderName]) {
//            
////            peerAddr.ip = user.privateIp;
////            peerAddr.port =
////            _socket.localPeers addObject:<#(id)#>
//        }
        
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
    if (_socket) {
        [_socket sendPacketToPeers:msgData];
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


-(void)socket:(AMHolePunchingSocket *)socket didFailWithError:(NSError *)error{
    
}

-(void)socket:(AMHolePunchingSocket *)socket didReceiveData:(NSData *)data{
    
}

-(void)socket:(AMHolePunchingSocket *)socket didNotSendData:(NSError *)err{
    
}


@end
