//
//  AMChatViewController.m
//  DemoUI
//
//  Created by Wei Wang on 4/19/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMChatViewController.h"
#import "AMMesher/AMMesher.h"
#import "AMMesher/AMAppObjects.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMNetworkUtils/AMHolePunchingSocket.h"
#import "AMMesher/AMMesherStateMachine.h"

@interface AMChatViewController ()

- (void)showChatRecord:(NSDictionary *)record;

@end

@implementation AMChatViewController
{
    AMHolePunchingSocket *_socket;
    AMGroup* _myGroup;
    
    NSMutableDictionary* _localPeerSet;
    NSMutableDictionary* _remotePeerSet;
    
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
        _localPeerSet = [[NSMutableDictionary alloc]init];
        _remotePeerSet = [[NSMutableDictionary alloc] init];
        _myPubIp = @"";
        _myNATPort = @"";
        _myInternalPort = @"";
    }
    return self;
}


-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userGroupsChanged:) name: AM_LOCALUSERS_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userGroupsChanged:) name: AM_REMOTEGROUPS_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineStatusChanged:) name: AM_MESHER_ONLINE_CHANGED object:nil];

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
    AMUser* mySelf = [[AMAppObjects appObjects] objectForKey:AMMyselfKey];
    NSAssert(mySelf, @"myself can not be nil");
    if (mySelf.isOnline == YES) {
        [_socket startHolePunching];
    }else{
        [_socket stopHolePunching];
    }
}


-(void)userGroupsChanged:(NSNotification*) notification
{
    AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
   if (machine.mesherState != kMesherMeshed &&
       machine.mesherState != kMesherStarted &&
       machine.mesherState != kMesherUnmeshing){
       return;
   }
    
    
    AMUser* mySelf = [AMAppObjects appObjects][AMMyselfKey];
    AMGroup* myGroup = [AMAppObjects appObjects][AMLocalGroupKey];
    
    NSMutableArray* joinedUsers = [[NSMutableArray alloc] init];
    
    if (mySelf.isOnline == NO) {
        [_remotePeerSet removeAllObjects];
        
        for (AMUser* user in myGroup.users) {
            if (nil == [_localPeerSet objectForKey:user.userid]) {
                [joinedUsers addObject:user];
                [_localPeerSet setObject:user forKey:user.userid];
            }
        }

    }else{
    
        NSString *mergedGroupId = [AMAppObjects appObjects][AMMergedGroupIdKey];
        NSDictionary *groups = [AMAppObjects appObjects][AMRemoteGroupsKey];
        NSArray* newUserlist = [groups[mergedGroupId] users];
        
        for (AMUser* newUser in newUserlist) {
            
            if (nil == [_localPeerSet objectForKey:newUser.userid] &&
                nil == [_remotePeerSet objectForKey:newUser.userid]) {
                [joinedUsers addObject:newUser];
            }
        }
        
        [_localPeerSet removeAllObjects];
        [_remotePeerSet removeAllObjects];
        
        for (AMUser* newUser in newUserlist) {
            BOOL bFind = NO;
            for (AMUser* user in myGroup.users) {
                if ([user.userid isEqualToString:newUser.userid]) {
                    bFind = YES;
                }
            }
        
            if (!bFind) {
                 [_remotePeerSet setObject:newUser forKey:newUser.userid];
            }else{
                [_localPeerSet setObject:newUser forKey:newUser.userid];
            }
        }
    }
    
    NSMutableArray* socketLocalPeers = [[NSMutableArray alloc] init];
    for (NSString* luKey in _localPeerSet) {
        AMUser* lu = [_localPeerSet objectForKey:luKey];
        AMHolePunchingPeer* lPeer = [[AMHolePunchingPeer alloc] init];
        lPeer.ip = lu.privateIp;
        lPeer.port = lu.chatPort;
        [socketLocalPeers addObject:lPeer];
    }
    
    NSMutableArray* socketRemotePeers = [[NSMutableArray alloc] init];
    for (NSString* ruKey in _remotePeerSet) {
        AMUser* ru = [_remotePeerSet objectForKey:ruKey];
        AMHolePunchingPeer* rPeer = [[AMHolePunchingPeer alloc] init];
        rPeer.ip = ru.publicIp;
        rPeer.port = ru.publicChatPort;
        [socketRemotePeers addObject:rPeer];
    }
    
    _socket.localPeers = socketLocalPeers;
    _socket.remotePeers = socketRemotePeers;
    
    [self performSelectorOnMainThread:@selector(showNewCommers:) withObject:joinedUsers waitUntilDone:NO];
    return;
}


-(void)showNewCommers:(id)newCommers
{
    for (AMUser* newUser in newCommers) {
        NSDictionary *record = @{
                                 @"sender"  : @"SYSTEM",
                                 @"message" : [NSString stringWithFormat:@"%@ JOINED THE GROUP",
                                               newUser.nickName],
                                 @"time"    : [NSDate date]
                                 };
        [self showChatRecord:record];
    }
}


- (IBAction)sendMsg:(id)sender
{
    NSString* msg = [self.chatMsgField stringValue];
    if(msg == nil || [msg isEqualToString:@""]){
        return;
    }

    AMUser* mySelf = [[AMAppObjects appObjects] objectForKey:AMMyselfKey];
    NSAssert(mySelf, @"myself can not be nil");
    NSString* nickName = mySelf.nickName;

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
    
    @try {
        NSDictionary *chatRecord = [NSKeyedUnarchiver unarchiveObjectWithData:data];
         [self showChatRecord:chatRecord];
    }
    @catch ( NSException *exception) {
        NSLog(@"An Error packets is send to Chat module: %@", exception.description);
    }
    @finally {
        //do nothing;
    }
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
    
        AMUser* meSelf = [[AMAppObjects appObjects] objectForKey:AMMyselfKey];
        meSelf.publicIp = _myPubIp;
        [[AMMesher sharedAMMesher] updateMySelf];
    }
    
    if(![_myNATPort isEqualToString:[ipAndPort objectAtIndex:1]]){
        
        _myNATPort = [ipAndPort objectAtIndex:1];
        AMUser* meSelf = [[AMAppObjects appObjects] objectForKey:AMMyselfKey];
        meSelf.publicChatPort = _myNATPort;
        
        [[AMMesher sharedAMMesher] updateMySelf];
        
        NSLog(@"go here!");
    }

}

@end
