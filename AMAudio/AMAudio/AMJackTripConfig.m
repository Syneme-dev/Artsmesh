//
//  AMJackTripConfig.m
//  AMAudio
//
//  Created by whiskyzed on 4/3/15.
//  Copyright (c) 2015 AM. All rights reserved.
//

#import "AMJackTripConfig.h"

//#import "AMJackTripConfigController.h"
#import "AMCoreData/AMCoreData.h"
#import "AMRouteViewController.h"
#import "AMJacktripConfigs.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "UIFramework/AMPopUpView.h"
#import "UIFramework/AMFoundryFontView.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMButtonHandler.h"
#import "AMAudio/AMAudio.h"
#import "UIFramework/AMWindow.h"

NSString * const AMJacktripLogNotification      = @"AMJacktripLogNotification";
@interface AMJackTripConfig ()<AMPopUpViewDelegeate, AMCheckBoxDelegeate>
{
    NSTimer*        _readTimer;
    NSString*       _logName;
}
@property (weak) IBOutlet AMPopUpView *backendSelecter;
@property (weak) IBOutlet AMPopUpView *roleSelecter;
@property (weak) IBOutlet AMPopUpView *peerSelecter;
@property (weak) IBOutlet AMFoundryFontView *peerAddress;
@property (weak) IBOutlet AMFoundryFontView *peerName;
@property (weak) IBOutlet AMPopUpView *portOffsetSelector;
@property (weak) IBOutlet NSTextField *rCount;
@property (weak) IBOutlet NSTextField *bitRateRes;
@property (weak) IBOutlet NSTextField *queueBufferLen;
@property (weak) IBOutlet AMCheckBoxView *zerounderrunCheck;
@property (weak) IBOutlet AMCheckBoxView *loopbackCheck;
@property (weak) IBOutlet AMCheckBoxView *ipv6Check;
@property (weak) IBOutlet NSTextField *channeCount;
@property (weak) IBOutlet NSTextField *recvCount;
@property (weak) IBOutlet NSButton *connectButton;
@property (weak) IBOutlet NSButton *disconnectButton;
@property (weak) IBOutlet NSButton *closeButton;
@property NSArray* allUsers;
@property  AMLiveUser* curPeer;
@end


@implementation AMJackTripConfig

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self setUpUI];
    [self loadDefaultPref];
    [self setPeerList];
    [self initPortOffset];
}

-(void)setUpUI
{
    [AMButtonHandler changeTabTextColor:self.connectButton      toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.disconnectButton   toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.closeButton        toColor:UI_Color_blue];
    
    [self.connectButton.layer setBorderWidth:1.0];
    [self.connectButton.layer setBorderColor: UI_Color_blue.CGColor];
    [self.disconnectButton.layer setBorderWidth:1.0];
    [self.disconnectButton.layer setBorderColor: UI_Color_blue.CGColor];
    [self.closeButton.layer  setBorderWidth:1.0];
    [self.closeButton.layer  setBorderColor: UI_Color_blue.CGColor];

    [self.backendSelecter addItemWithTitle:@"JACK"];
    [self.backendSelecter addItemWithTitle:@"RtAudio"];
    
    [self.roleSelecter addItemWithTitle:@"P2P SERVER"];
    [self.roleSelecter addItemWithTitle:@"P2P CLIENT"];
    [self.roleSelecter addItemWithTitle:@"HUB SERVER"];
    [self.roleSelecter addItemWithTitle:@"HUB CLIENT"];
    
    [self.peerAddress setEnabled:NO];
    [self.peerName setEnabled:NO];
    
    self.portOffsetSelector.delegate = self;
    self.roleSelecter.delegate = self;
    self.peerSelecter.delegate = self;
    
    self.zerounderrunCheck.title = @"ZERO UNDER RUN";
    self.loopbackCheck.title = @"LOOPBACK";
    self.ipv6Check.title = @"USE IPV6";
    self.ipv6Check.delegate = self;
}


-(void)setPeerList
{
    AMCoreData* dataStore = [AMCoreData shareInstance];
    AMLiveUser* mySelf = dataStore.mySelf;
    
    if (!mySelf.isOnline)
    {
        self.allUsers = dataStore.myLocalLiveGroup.users;
    }else{
        AMLiveGroup* mergedGroup = [dataStore mergedGroup];
        self.allUsers = [mergedGroup usersIncludeSubGroup];
    }
    
    int firstIndexInUserlist = -1;
    for (int i = 0; i < [self.allUsers count]; i++) {
        
        AMLiveUser* user = self.allUsers[i];
        
        //Two User at most have one connection
        BOOL alreadyConnect = NO;
        for(AMJacktripInstance* jacktrip in [[AMAudio sharedInstance] audioJacktripManager].jackTripInstances){
            if ([user.nickName isEqualToString:jacktrip.instanceName]){
                alreadyConnect = YES;
                break;
            }
        }
        
        if (alreadyConnect) {
            continue;
        }
        
        if([user.userid isNotEqualTo:mySelf.userid]){
            [self.peerSelecter addItemWithTitle:user.nickName];
            firstIndexInUserlist = (firstIndexInUserlist == -1)?i:firstIndexInUserlist;
        }
    }
    
    [self.peerSelecter addItemWithTitle:@"ip address"];
    
    if (firstIndexInUserlist == -1) {
        //no one add to list except ip address
        [self.peerAddress setEnabled:YES];
        self.peerAddress.stringValue = @"";
        
        [self.peerName setEnabled:YES];
        self.peerName.stringValue = @"";
        
    }else{
        //auto select a user
        if (!mySelf.isOnline) {
            self.peerAddress.stringValue = [self.allUsers[firstIndexInUserlist]
                                            privateIp];
        }else{
            
            //TODO: bug! if local groupmates meshed, can not use private ip
            self.peerAddress.stringValue = [self.allUsers[firstIndexInUserlist]
                                            publicIp];
        }
        
        self.peerName.stringValue = [self.allUsers [firstIndexInUserlist]
                                     nickName];
        [self.peerAddress setEnabled:NO];
        [self.peerName setEnabled:NO];
    }
    
    [self.peerSelecter selectItemAtIndex:0];
}


-(void)itemSelected:(AMPopUpView*)sender
{
    if ([sender isEqual:self.peerSelecter]) {
        [self peerSelectedChanged:sender];
    }
}


-(void)initPortOffset
{
    [self.portOffsetSelector removeAllItems];
    
    for (NSUInteger i = 0; i <10; i++) {
        
        BOOL inUse = NO;
        for (AMJacktripInstance* jacktrip in [[AMAudio sharedInstance] audioJacktripManager].jackTripInstances) {
            if(jacktrip.portOffset == i){
                inUse = YES;
                break;
            }
        }
        
        if(!inUse){
            NSString* str = [NSString stringWithFormat:@"%lu", (unsigned long)i];
            [self.portOffsetSelector addItemWithTitle:str];
        }
    }
    
    [self.portOffsetSelector selectItemAtIndex:0];
}


-(void)loadDefaultPref
{
    [self.backendSelecter selectItemWithTitle:@"JACK"];
    
    NSString *roleStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_Role];
    [self.roleSelecter selectItemWithTitle:roleStr];
    
    NSString *chanCountStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_ChannelCount];
    self.channeCount.stringValue = chanCountStr;
    
    NSString *recvCountStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_RecvCount];
    self.recvCount.stringValue = recvCountStr;
    
    NSString *qblStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_QBL];
    self.queueBufferLen.stringValue = qblStr;
    
    NSString *prStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_PR];
    self.rCount.stringValue = prStr;
    
    NSString *brrStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_BRR];
    self.bitRateRes.stringValue = brrStr;
    
    NSString *zeroStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_ZeroUnderRun];
    if ([zeroStr isEqualToString:@"YES"]) {
        self.zerounderrunCheck.checked = YES;
    }else{
        self.zerounderrunCheck.checked = NO;
    }
    
    NSString *loopStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_Loopback];
    if ([loopStr isEqualToString:@"YES"]) {
        self.loopbackCheck.checked = YES;
    }else{
        self.loopbackCheck.checked = NO;
    }
    
    NSString *useIpv6Str = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_UseIpv6];
    if ([useIpv6Str isEqualToString:@"YES"]) {
        self.ipv6Check.checked = YES;
    }else{
        self.ipv6Check.checked = NO;
    }
    
}


- (void)peerSelectedChanged:(AMPopUpView *)sender
{
    if ([self.peerSelecter.stringValue isEqualToString:@"ip address"]) {
        
        [self.peerAddress setEnabled:YES];
        [self.peerName setEnabled:YES];
        
        self.peerAddress.stringValue = @"";
        self.peerName.stringValue = @"";
        
    }else{
        [self.peerAddress setEnabled:NO];
        [self.peerName setEnabled:NO];
        
        AMCoreData* sharedStore = [AMCoreData shareInstance];
        AMLiveUser* mySelf = sharedStore.mySelf;
        
        for (AMLiveUser* user in self.allUsers) {
            
            if([user.nickName isEqualToString:self.peerSelecter.stringValue]){
                // We just distingush the private/public ip on ipv4
                if (!self.ipv6Check.checked) {
                    if(!mySelf.isOnline){
                        self.peerAddress.stringValue = user.privateIp;
                    }else{
                        self.peerAddress.stringValue = user.publicIp;
                    }
                }else{ //when the ipv6 checked, we just use
                    self.peerAddress.stringValue = user.ipv6Address;
                }
                
                break;
            }
        }
        
        self.peerName.stringValue = self.peerSelecter.stringValue;
    }
}


-(BOOL)checkouJacktripParams
{
    if ([self.roleSelecter.stringValue isNotEqualTo:@"P2P SERVER"] &&
        [self.roleSelecter.stringValue isNotEqualTo:@"P2P CLIENT"] &&
        [self.roleSelecter.stringValue isNotEqualTo:@"HUB SERVER"] &&
        [self.roleSelecter.stringValue isNotEqualTo:@"HUB CLIENT"]) {
            return NO;
    }
    
    if ([self.roleSelecter.stringValue isEqualTo:@"P2P SERVER"] ||
        [self.roleSelecter.stringValue isEqualTo:@"HUB SERVER"]){
        if ([self.peerName.stringValue isEqualTo:@""]) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Parameter Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"For a jacktrip server role you must enter clientname."];
            [alert runModal];
            return NO;
        }
        
    }else if([self.peerAddress.stringValue isEqualTo:@""] &&
             [self.peerName.stringValue isEqualTo:@""])
    {
       
            NSAlert *alert = [NSAlert alertWithMessageText:@"Parameter Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"For a jacktrip client role you must enter both ip address and clientname "];
            [alert runModal];
            return NO;
        
    }
    
    //check illegal ip address
    //TODO:
    
    if ([self.channeCount.stringValue intValue] <= 0) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Parameter Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"channel count parameter can not be less than zero"];
        [alert runModal];
        return NO;
    }

    if ([self.recvCount.stringValue intValue] <= 0) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Parameter Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"recv channel count parameter can not be less than zero"];
        [alert runModal];
        return NO;
    }
    
    if ([self.queueBufferLen.stringValue intValue] <= 0) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Parameter Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"queue buffer parameter can not be less than zero"];
        [alert runModal];
        return NO;
    }
    
    if ([self.rCount.stringValue intValue] <= 0) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Parameter Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"rcount parameter can not be less than zero"];
        [alert runModal];
        return NO;
    }
    
    if ([self.bitRateRes.stringValue intValue] <= 0) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Parameter Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"bitRateRes parameter can not be less than zero"];
        [alert runModal];
        return NO;
    }
    
    for(AMJacktripInstance* jacktrip in [[AMAudio sharedInstance] audioJacktripManager].jackTripInstances){
        if([jacktrip.instanceName isEqualToString:self.peerName.stringValue]){
            
            NSAlert *alert = [NSAlert alertWithMessageText:@"duplicate user!" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Already have one jacktrip connection with that user."];
            [alert runModal];
            return NO;
        }
    }
    
    //check channel count;
    int totalChannels = 0;
    for (AMJacktripInstance* instance in [[AMAudio sharedInstance] audioJacktripManager].jackTripInstances){
        totalChannels += instance.channelCount;
    }
    
    if (self.maxChannels < totalChannels + [self.channeCount.stringValue intValue]) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Too many channels" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"There are already too many channels, you must close some deviecs!"];
        [alert runModal];
        return NO;
    }
    
    return YES;
}

- (IBAction)connectJack:(NSButton *)sender
{
    if (![self checkouJacktripParams]) {
        return;
    }
    
    NSString *jamLink = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_Jamlink];
    
    AMJacktripConfigs* cfgs = [[AMJacktripConfigs alloc] init];
    
    cfgs.backend        = self.backendSelecter.stringValue;
    cfgs.role           = self.roleSelecter.stringValue;
    cfgs.serverAddr     = self.peerAddress.stringValue;
    cfgs.portOffset     = self.portOffsetSelector.stringValue;
    cfgs.channelCount   = self.channeCount.stringValue;
    cfgs.recvCount      = self.recvCount.stringValue;
    cfgs.qBufferLen     = self.queueBufferLen.stringValue;
    cfgs.rCount         = self.rCount.stringValue;
    cfgs.bitrateRes     = self.bitRateRes.stringValue;
    cfgs.zerounderrun   = self.zerounderrunCheck.checked;
    cfgs.loopback       = self.loopbackCheck.checked;
    cfgs.jamlink        = [jamLink boolValue];
    cfgs.clientName     = self.peerName.stringValue;
    cfgs.useIpv6        = self.ipv6Check.checked;
    
    NSString *hubPatch      = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_HubPatch];
    cfgs.hubPatch       = hubPatch;
    
    NSString *bufStrategy   = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_BufStrategy];
    cfgs.bufStrategy     = bufStrategy;
    
    NSString *incServerStr  = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_IncludeServer];
    cfgs.includeServer     = [incServerStr boolValue];
    
    NSString *moToStereoStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_MonoToStereo];
    cfgs.monoToStereo     = [moToStereoStr boolValue];
    
    // JackAudio Configs

    NSString *sampleRate   = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jack_SampleRate];
    cfgs.samplingRate     = sampleRate;
    
    NSString *bufferSize   = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jack_BufferSize];
    cfgs.bufferSize     = bufferSize;
    
    NSString *inputDevice   = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jack_InputDevice];
    cfgs.inputDevice     = inputDevice;
    
    NSString *outputDevice  = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jack_OutputDevice];
    cfgs.outputDevice     = outputDevice;
    
    
    if(![[[AMAudio sharedInstance] audioJacktripManager] startJacktrip:cfgs]){
        
        NSAlert *alert = [NSAlert alertWithMessageText:@"start jacktrip failed!" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"maybe port conflict!"];
        [alert runModal];
    }
    
    _logName = [[NSMutableString alloc]
                initWithFormat:@"jacktrip_%@.log", [self.peerName stringValue]];
    
    if([cfgs.backend isEqualToString:@"JACK"] &&
       [cfgs.role    isEqualToString:@"HUB SERVER"]){
        [self.connectButton setTitle:@"CONNECTED"];
        [self.connectButton setEnabled:NO];
        
        _readTimer =[NSTimer scheduledTimerWithTimeInterval:2
                                                     target:self
                                                   selector:@selector(sendLogName:)
                                                   userInfo:nil
                                                    repeats:YES];
    }
    else{
        [[NSNotificationCenter defaultCenter]
                        postNotificationName:AMJacktripLogNotification
                                    object:_logName];
        [self.window close];
    }
}

- (void) sendLogName:(NSTimer*) timer
{
    [[NSNotificationCenter defaultCenter]
                    postNotificationName:AMJacktripLogNotification
                                object:_logName];
}


- (IBAction) disconnectJack:(NSButton *)sender
{
    [[[AMAudio sharedInstance] audioJacktripManager] stopAllJacktrips];
    system("killall jacktrip >/dev/null");
    [self.window close];
}


- (IBAction)closeWindow:(NSButton *)sender
{
    [_readTimer invalidate];
    [self.window close];
}


- (void) onChecked:(AMCheckBoxView *)sender
{
    if (sender == self.ipv6Check) {
        [self peerSelectedChanged:self.peerSelecter];
    }
}
@end
