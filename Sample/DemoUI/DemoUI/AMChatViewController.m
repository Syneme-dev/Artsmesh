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
#import "AMStatusNetModule/AMStatusNetModule.h"
#import "AMNetworkUtils/AMHolePunchingSocket.h"

@interface AMChatViewController ()

- (void)showChatRecord:(NSDictionary *)record;

@end

@implementation AMChatViewController
{
    AMHolePunchingSocket *_socket;
    AMGroup* _myGroup;
    NSString* _myPubIp;
    NSString* _myInternalPort;
    NSString* _myNATPort;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _chatRecords = [[NSMutableArray alloc] init];
        _myPubIp = @"";
        _myNATPort = @"";
        _myInternalPort = @"";
    }
    return self;
}

/*

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userGroupsChanged:) name:AM_USERGROUPS_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineStatusChanged:) name:AM_MESHER_ONLINE object:nil];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* addr = [defaults stringForKey:Preference_Key_General_StunServerAddr];
    NSString* port = [defaults stringForKey:Preference_Key_General_StunServerPort];
    _myInternalPort = [defaults stringForKey:Preference_Key_General_ChatPort];
    
    _socket = [[AMHolePunchingSocket alloc] initWithServer: addr serverPort:port clientPort: _myInternalPort];
    _socket.useIpv6 = [[defaults stringForKey:Preference_Key_General_UseIpv6] boolValue];
    
    [_socket initSocket];
    _socket.delegate = self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}

-(void)onlineStatusChanged:(NSNotification*) notification
{
    BOOL isOnline = [notification.userInfo[@"IsOnline"] boolValue];
    if (isOnline == YES) {
        [_socket startHolePunching];
    }else{
        [_socket stopHolePunching];
    }
}


-(void)userGroupsChanged:(NSNotification*) notification
{
    NSMutableArray* joinedUsers = nil;
    AMGroup* myNewGroup = [[AMMesher sharedAMMesher] myGroup];

    if (_myGroup != nil) {
        joinedUsers = [[NSMutableArray alloc] init];
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
    }
    
    _myGroup = myNewGroup;
    
    if (joinedUsers != nil ) {
        [self performSelectorOnMainThread:@selector(showNewCommers:) withObject:joinedUsers waitUntilDone:NO];
    }
    
    [self updatePortInfo];
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


-(void)updatePortInfo
{
    NSMutableArray* localPeers = [[NSMutableArray alloc]  init];
    NSMutableArray* remotePeers = [[NSMutableArray alloc]  init];
    
    AMMesher* mesher = [AMMesher sharedAMMesher];
    NSString* myLocalLeaderName = mesher.mySelf.localLeader;
    
    for (AMUser* user in _myGroup.users) {
        AMHolePunchingPeer* peerAddr = [[AMHolePunchingPeer alloc] init];
        for (AMUserPortMap* pm in user.portMaps) {
            if ([pm.portName isEqualToString:@"ChatPort"]) {
                if ([ user.localLeader isEqualToString:myLocalLeaderName]){
                    peerAddr.ip = user.privateIp;
                    peerAddr.port = pm.internalPort;
                    [localPeers addObject:peerAddr];
                }else{
                    peerAddr.ip = user.publicIp;
                    peerAddr.port = pm.natMapPort;
                    [remotePeers addObject:peerAddr];
                }
            }
        }
    }

    _socket.localPeers = localPeers;
    _socket.remotePeers = remotePeers;
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
    NSLog(@"chat socket failed: %@", error.description);
}

-(void)socket:(AMHolePunchingSocket *)socket didReceiveData:(NSData *)data{
    
    NSDictionary *chatRecord = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self showChatRecord:chatRecord];

}

-(void)socket:(AMHolePunchingSocket *)socket didNotSendData:(NSError *)err{
    NSLog(@"chat message did not send out: %@", err.description);
}

-(void)socket:(AMHolePunchingSocket *)socket didReceiveDataFromServer:(NSData *)data{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray* ipAndPort = [msg componentsSeparatedByString:@":"];
    if ([ipAndPort count] < 2){
        return;
    }
    
    if(![_myPubIp isEqualToString:[ipAndPort objectAtIndex:0]]){
        _myPubIp = [ipAndPort objectAtIndex:0];
        
        NSDictionary* dict = @{@"publicIp": _myPubIp};
        AMMesher* mesher = [AMMesher sharedAMMesher];
        [mesher setMySelfPropties:dict];
    }
    
    if(![_myNATPort isEqualToString:[ipAndPort objectAtIndex:1]]){
        _myNATPort = [ipAndPort objectAtIndex:1];
        
        AMUserPortMap *portMap = [[AMUserPortMap alloc] init];
        portMap.portName = @"ChatPort";
        portMap.natMapPort =  _myNATPort;
        portMap.internalPort = _myInternalPort;
        AMMesher* mesher = [AMMesher sharedAMMesher];
        [mesher setPortMaps:portMap];
    }

}

*/
@end
