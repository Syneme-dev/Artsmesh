//
//  AMJackTripConfigController.m
//  AMAudio
//
//  Created by Wei Wang on 9/5/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMJackTripConfigController.h"
#import "AMCoreData/AMCoreData.h"
#import "AMRouteViewController.h"
#import "AMJacktripConfigs.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "UIFramework/AMPopUpView.h"
#import "UIFramework/AMFoundryFontView.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMButtonHandler.h"

@interface AMJackTripConfigController ()<AMPopUpViewDelegeate, AMCheckBoxDelegeate>
@property (weak) IBOutlet AMPopUpView *roleSelecter;
@property (weak) IBOutlet AMPopUpView *peerSelecter;
@property (weak) IBOutlet AMFoundryFontView *peerAddress;
@property (weak) IBOutlet AMFoundryFontView *peerName;
@property (weak) IBOutlet AMPopUpView *portOffsetSelector;
@property (weak) IBOutlet NSTextField *rCount;
@property (weak) IBOutlet NSTextField *bitRateRes;
@property (weak) IBOutlet AMCheckBoxView *zerounderrunCheck;
@property (weak) IBOutlet AMCheckBoxView *loopbackCheck;
@property (weak) IBOutlet AMCheckBoxView *ipv6Check;
@property (weak) IBOutlet NSButton *createBtn;
@property (weak) IBOutlet NSTextField *channeCount;
@property (weak) IBOutlet NSButton *closeBtn;

@property NSArray* allUsers;

@end

@implementation AMJackTripConfigController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}


-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(jacktripChanged:)
     name:AM_RELOAD_JACK_CHANNEL_NOTIFICATION
     object:nil];
    
    [self setUpUI];
    [self loadDefaultPref];
}

-(void)setUpUI
{
    [AMButtonHandler changeTabTextColor:self.createBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.closeBtn toColor:UI_Color_blue];
    
    [self.roleSelecter addItemWithTitle:@"Server"];
    [self.roleSelecter addItemWithTitle:@"Client"];
    
    [self.peerAddress setEnabled:NO];
    [self.peerName setEnabled:NO];
    
    self.portOffsetSelector.delegate = self;
    self.roleSelecter.delegate = self;
    self.peerSelecter.delegate = self;
    
    self.zerounderrunCheck.title = @"ZERO UNDER RUN";
    self.loopbackCheck.title = @"LOOPBACK";
    self.ipv6Check.title = @"USE IPV6";
    
    [self setPeerList];
    [self initPortOffset];
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
        for(AMJacktripInstance* jacktrip in self.jacktripManager.jackTripInstances){
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
        for (AMJacktripInstance* jacktrip in self.jacktripManager.jackTripInstances) {
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
    NSString *roleStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_Role];
    [self.roleSelecter selectItemWithTitle:roleStr];
    
    NSString *chanCountStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_ChannelCount];
    self.channeCount.stringValue = chanCountStr;
    
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
                
                if(!mySelf.isOnline){
                    self.peerAddress.stringValue = user.privateIp;
                }else{
                    self.peerAddress.stringValue = user.publicIp;
                }
                
                break;
            }
        }
        
        self.peerName.stringValue = self.peerSelecter.stringValue;
    }
}


-(BOOL)checkouJacktripParams
{
    if ([self.roleSelecter.stringValue isNotEqualTo:@"Server"] &&
        [self.roleSelecter.stringValue isNotEqualTo:@"Client"]) {
        return NO;
    }
    
    if ([self.roleSelecter.stringValue isEqualTo:@"Server"]){
        if ([self.peerName.stringValue isEqualTo:@""]) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Parameter Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"For a jacktrip server role you must enter clientname."];
            [alert runModal];
            return NO;
        }
        
    }else if([self.roleSelecter.stringValue isEqualTo:@"Client"]||
             [self.peerAddress.stringValue isEqualTo:@""]){
        if([self.peerName.stringValue isEqualTo:@""]){
            NSAlert *alert = [NSAlert alertWithMessageText:@"Parameter Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"For a jacktrip client role you must enter both ip address and clientname "];
            [alert runModal];
            return NO;
        }
    }

    //check illegal ip address
    //TODO:
    
    if ([self.channeCount.stringValue intValue] <= 0) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Parameter Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"channel count parameter can not be less than zero"];
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
    
    for(AMJacktripInstance* jacktrip in self.jacktripManager.jackTripInstances){
        if([jacktrip.instanceName isEqualToString:self.peerName.stringValue]){
            
            NSAlert *alert = [NSAlert alertWithMessageText:@"duplicate user!" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Already have one jacktrip connection with that user."];
            [alert runModal];
            return NO;
        }
    }
    
    //check channel count;
    int totalChannels = 0;
    for (AMJacktripInstance* instance in self.jacktripManager.jackTripInstances){
        totalChannels += instance.channelCount;
    }
    
    if (self.maxChannels < totalChannels + [self.channeCount.stringValue intValue]) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Too many channels" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"There are already too many channels, you must close some deviecs!"];
        [alert runModal];
        return NO;
    }

    return YES;
}

- (IBAction)startJacktrip:(NSButton *)sender
{
    if (![self checkouJacktripParams]) {
        return;
    }
    
    NSString *qCount = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_QBL];
    NSString *jamLink = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_Jamlink];
    
    AMJacktripConfigs* cfgs = [[AMJacktripConfigs alloc] init];
    
    cfgs.role = self.roleSelecter.stringValue;
    cfgs.serverAddr = self.peerAddress.stringValue;
    cfgs.portOffset = self.portOffsetSelector.stringValue;
    cfgs.channelCount = self.channeCount.stringValue;
    cfgs.qCount = qCount;
    cfgs.rCount = self.rCount.stringValue;
    cfgs.bitrateRes = self.bitRateRes.stringValue;
    cfgs.zerounderrun = self.zerounderrunCheck.checked;
    cfgs.loopback = self.loopbackCheck.checked;
    cfgs.jamlink = [jamLink boolValue];
    cfgs.clientName = self.peerName.stringValue;
    cfgs.useIpv6 = self.ipv6Check.checked;
    
    if(![self.jacktripManager startJacktrip:cfgs]){
       
        NSAlert *alert = [NSAlert alertWithMessageText:@"start jacktrip failed!" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"maybe port conflict!"];
        [alert runModal];
    }
    
    [self.owner performClose:nil];
}

-(void)jacktripChanged:(NSNotification*)notification
{

}

- (IBAction)closeClicked:(NSButton *)sender
{
    [self.owner performClose:nil];
}

@end
