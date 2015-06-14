//
//  AMChatViewController.m
//  DemoUI
//
//  Created by Wei Wang on 4/19/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMChatViewController.h"
#import "AMCoreData/AMCoreData.h"
#import "AMMesher/AMMesher.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMNetworkUtils/AMHolePunchingSocket.h"
#import "AMLogger/AMLogger.h"
#import "AMOSCGroups/AMOSCGroups.h"
#import "AMChatTableCellView.h"
#import "AMStatusNet/AMStatusNet.h"
#import "UIFramework/AMCheckBoxView.h"

@interface AMChatViewController () <NSTextFieldDelegate, AMCheckBoxDelegeate>
@property (weak) IBOutlet AMCheckBoxView *useOSC;

- (void)showChatRecord:(NSDictionary *)record;

@end

@implementation AMChatViewController
{
    AMHolePunchingSocket *_socket;
    AMLiveGroup* _myGroup;
    
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
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* addr = [defaults stringForKey:Preference_Key_General_StunServerAddr];
    NSString* port = [defaults stringForKey:Preference_Key_General_StunServerPort];
    _myInternalPort = [defaults stringForKey:Preference_Key_General_ChatPort];
    
    _socket = [[AMHolePunchingSocket alloc] initWithServer: addr serverPort:port clientPort: _myInternalPort];
    _socket.useIpv6 = [[defaults stringForKey:Preference_Key_General_MeshUseIpv6] boolValue];
    
    [_socket initSocket];
    _socket.delegate = self;
    
    _chatMsgField.delegate = self;
    
    [self userGroupsChanged:nil];
    [self onlineStatusChanged:nil];
    
    
    self.useOSC.delegate = self;
    self.useOSC.title = @"USE OSC";
    if ([[NSUserDefaults standardUserDefaults] boolForKey:Preference_Key_General_UseOSCForChat]) {
        self.useOSC.checked = YES;
    }else{
        self.useOSC.checked = NO;
    }

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userGroupsChanged:) name: AM_LIVE_GROUP_CHANDED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatMessageFromOSC:) name:AM_CHAT_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:nil];
}

-(void)dealloc{
    [_socket closeSocket];
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}


-(void)onlineStatusChanged:(NSNotification*) notification
{
}


-(void)userGroupsChanged:(NSNotification*) notification
{
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    AMLiveGroup* myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    
    NSMutableArray* joinedUsers = [[NSMutableArray alloc] init];
    
    if (mySelf.isOnline == NO) {
        [_remotePeerSet removeAllObjects];
        
        for (AMLiveUser* user in myGroup.users) {
            if (nil == [_localPeerSet objectForKey:user.userid]) {
                [joinedUsers addObject:user];
                [_localPeerSet setObject:user forKey:user.userid];
            }
        }

    }else{
        NSArray* newUserlist = nil;
        
        AMLiveGroup* mergedGroup = [[AMCoreData shareInstance] mergedGroup];
        if (mergedGroup == nil) {
            newUserlist = [myGroup usersIncludeSubGroup];
        }else{
            newUserlist = [mergedGroup usersIncludeSubGroup];
        }
        
        for (AMLiveUser* newUser in newUserlist) {
            
            if (nil == [_localPeerSet objectForKey:newUser.userid] &&
                nil == [_remotePeerSet objectForKey:newUser.userid]) {
                [joinedUsers addObject:newUser];
            }
        }
        
        [_localPeerSet removeAllObjects];
        [_remotePeerSet removeAllObjects];
        
        for (AMLiveUser* newUser in newUserlist) {
            BOOL bFind = NO;
            for (AMLiveUser* user in myGroup.users) {
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
        AMLiveUser* lu = [_localPeerSet objectForKey:luKey];
        AMHolePunchingPeer* lPeer = [[AMHolePunchingPeer alloc] init];
        lPeer.ip = lu.privateIp;
        lPeer.port = lu.chatPort;
        [socketLocalPeers addObject:lPeer];
    }
    
    NSMutableArray* socketRemotePeers = [[NSMutableArray alloc] init];
    for (NSString* ruKey in _remotePeerSet) {
        AMLiveUser* ru = [_remotePeerSet objectForKey:ruKey];
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


-(void)chatMessageFromOSC:(NSNotification *)notification
{
    NSDictionary *userInfo = (NSDictionary *)notification.object;
    if (userInfo) {
        NSArray *params = [userInfo objectForKey:AM_CHAT_MESSAGE_PARAMS];
        if (params) {
            
            NSData *chatData = [[params firstObject] objectForKey:@"BLOB"];
            if (chatData) {
                NSDictionary *record = [self recordFromData:chatData];
                if (record) {
                    [self showChatRecord:record];
                }
            }
        }
    }
}


-(void)showNewCommers:(id)newCommers
{
    for (AMLiveUser* newUser in newCommers) {
        NSDictionary *record = @{
                                 @"sender"  : @"System",
                                 @"message" : [NSString stringWithFormat:@"%@ joined the group",
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
    
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    NSString* nickName = mySelf.nickName;
    
    NSData *msgData = [NSKeyedArchiver archivedDataWithRootObject:
                       @{@"sender":nickName, @"message":msg, @"time":[NSDate date]}];
    
    BOOL useOSC = [[[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_General_UseOSCForChat] boolValue];
    if (useOSC) {
        if(![[AMOSCGroups sharedInstance] isOSCGroupClientStarted]){
            NSAlert *alert = [NSAlert alertWithMessageText:@"OSC Client hasn't Started!" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
            [alert runModal];
            return;
        }else{
            [[AMOSCGroups sharedInstance] broadcastMessage:AM_CHAT_MESSAGE params:@[@{@"BLOB":msgData}]];
        }
    }else{
        if (_socket) {
            [_socket sendPacketToPeers:msgData];
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


-(NSDictionary *)recordFromData:(NSData *)data
{
    NSDictionary *chatRecord;
    
    @try {
        chatRecord = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    @catch ( NSException *exception) {
        AMLog(kAMErrorLog, @"AMChat",@"An Error packets is send to Chat module: %@", exception.description);
    }
    @finally {
        return chatRecord;
    }
}


-(void)socket:(AMHolePunchingSocket *)socket didFailWithError:(NSError *)error{
    AMLog(kAMErrorLog, @"AMChat", @"chat socket failed: %@", error.description);
}

-(void)socket:(AMHolePunchingSocket *)socket didReceiveData:(NSData *)data{
    
    NSDictionary *record = [self recordFromData:data];
    if (record) {
        [self showChatRecord:record];
    }
}

-(void)socket:(AMHolePunchingSocket *)socket didNotSendData:(NSError *)err{
    AMLog(kAMErrorLog, @"AMChat",@"chat message did not send out: %@", err.description);
}

-(void)socket:(AMHolePunchingSocket *)socket didReceiveDataFromServer:(NSData *)data{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray* ipAndPort = [msg componentsSeparatedByString:@":"];
    if ([ipAndPort count] < 2){
        return;
    }
    
    if(![_myPubIp isEqualToString:[ipAndPort objectAtIndex:0]]){
        _myPubIp = [ipAndPort objectAtIndex:0];
    
        AMLiveUser* meSelf = [AMCoreData shareInstance].mySelf;
        meSelf.publicIp = _myPubIp;

        [[AMMesher sharedAMMesher] updateMySelf];
    }
    
    if(![_myNATPort isEqualToString:[ipAndPort objectAtIndex:1]]){
        
        _myNATPort = [ipAndPort objectAtIndex:1];
        AMLiveUser* meSelf = [AMCoreData shareInstance].mySelf;
        meSelf.publicChatPort = _myNATPort;
        
        [[AMMesher sharedAMMesher] updateMySelf];
    }

}


-(void)controlTextDidChange:(NSNotification *)obj
{
    if ([obj.object isKindOfClass:[NSTextField class]]) {
        NSTextField *textField = (NSTextField *)obj.object;
        
        if ([textField.stringValue length] > 1000) {
            
            NSAlert *alert = [NSAlert alertWithMessageText:@"Chat Message Length Should Less Than 1000 Characters!" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
            [alert runModal];
            
            textField.stringValue = [textField.stringValue substringToIndex:10];
            
        }
    }
}


- (BOOL)isCommandEnterEvent:(NSEvent *)e {
    NSUInteger flags = (e.modifierFlags & NSDeviceIndependentModifierFlagsMask);
    BOOL isCommand = (flags & NSCommandKeyMask) == NSCommandKeyMask;
    BOOL isEnter = (e.keyCode == 0x24); // VK_RETURN
    return (isCommand && isEnter);
}


- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView
doCommandBySelector:(SEL)commandSelector {
    if ([self isCommandEnterEvent:[NSApp currentEvent]]) {
        [self handleCommandEnter];
        return YES;
    }
    return NO;
}

- (void)handleCommandEnter {
    
    if ([self.chatMsgField.stringValue isEqualToString:@""]) {
        return;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = kCFDateFormatterShortStyle;
    formatter.timeStyle = kCFDateFormatterShortStyle;
    formatter.locale = [NSLocale systemLocale];
    
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    
    NSString* status = [NSString stringWithFormat:@"%@ said: %@ at %@ in group",
                        [AMCoreData shareInstance].mySelf.nickName,
                        self.chatMsgField.stringValue,
                        dateStr];
    [[AMStatusNet shareInstance] postMessageToStatusNet:status];
    
    [self sendMsg:self.chatMsgField];
}

#pragma mark AMCheckBoxDelegeate
-(void)onChecked:(AMCheckBoxView*)sender
{
    if (sender == self.useOSC) {
        
        if (self.useOSC.checked) {
            [[NSUserDefaults standardUserDefaults]
             setObject:@"YES" forKey:Preference_Key_General_UseOSCForChat];
        }else{
            [[NSUserDefaults standardUserDefaults]
             setObject:@"NO" forKey:Preference_Key_General_UseOSCForChat];
        }
    }
    return;
}


@end
