//
//  AMPreferenceManager.m
//  AMPreferenceManager
//
//  Created by Sky JIA on 12/30/13.
//  Copyright (c) 2013 Artsmesh. All rights reserved.
//


#import "AMPreferenceManager.h"
#import "AMCoreData/AMCoreData.h"
#import "AMCommonTools/AMCommonTools.h"



@implementation AMPreferenceManager

+(AMPreferenceManager*)shareInstance
{
    static AMPreferenceManager* sharedPreference = nil;
    @synchronized(self){
        if (sharedPreference == nil){
            sharedPreference = [[self alloc] privateInit];
        }
    }
    return sharedPreference;
}

- (instancetype)privateInit
{
    return [super init];
}

-(void)initPreference
{
    [self registerPreference];
    [self writePreferenceToData];
}

+ (NSUserDefaults *)standardUserDefaults {
    return [NSUserDefaults standardUserDefaults];
}

- (void)registerPreference {
    NSMutableArray *openedPanel=[[NSMutableArray alloc] init];
    [openedPanel addObject:@"User_Panel"];
    NSDictionary *registrationDomainDefaultsValues =
            [NSDictionary dictionaryWithObjectsAndKeys:
             Preference_General_ChatPort,        Preference_Key_General_ChatPort,
             Preference_User_Affiliation,        Preference_Key_User_Affiliation,
             Preference_User_Description,        Preference_Key_User_Description,
             Preference_User_Location,           Preference_Key_User_Location,
             Preference_User_NickName,           Preference_Key_User_NickName,
             Preference_User_FullName,           Preference_Key_User_FullName,
             Preference_User_PrivateIp,          Preference_Key_User_PrivateIp,
             Preference_General_StunServerAddr,  Preference_Key_General_StunServerAddr,
             Preference_General_StunServerPort,  Preference_Key_General_StunServerPort,
             Preference_General_GlobalServerAddr,Preference_Key_General_GlobalServerAddr,
             Preference_General_GlobalServerPort,Preference_Key_General_GlobalServerPort,
             Preference_General_LocalServerPort, Preference_Key_General_LocalServerPort,
             openedPanel,UserData_Key_OpenedPanel,
             Preference_Cluster_Name,            Preference_Key_Cluster_Name,
             Preference_Cluster_Description,     Preference_Key_Cluster_Description,
             Preference_Cluster_FullName,        Preference_Key_Cluster_FullName,
             Preference_Cluster_Location,        Preference_Key_Cluster_Location,
             Preference_Cluster_Project,         Preference_Key_Cluster_Project,
             @"YES",Preference_Key_General_TopControlBar,
            nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:registrationDomainDefaultsValues];

}

-(void)writePreferenceToData
{
    [self writeUserProfile];
    [self writeSystemConfig];
    [self writeGroupProfile];
}

-(void)writeUserProfile
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    AMLiveUser* mySelf = [[AMLiveUser alloc] init];
    mySelf.userid = [AMCommonTools creatUUID];
    mySelf.nickName = [defaults stringForKey:Preference_Key_User_NickName];
    mySelf.domain= [defaults stringForKey:Preference_Key_User_Affiliation];
    mySelf.location = [defaults stringForKey:Preference_Key_User_Location];
    mySelf.description = [defaults stringForKey:Preference_Key_User_Description];
    mySelf.privateIp = [defaults stringForKey:Preference_Key_User_PrivateIp];
    mySelf.publicIp = mySelf.privateIp;
    mySelf.chatPort = [defaults stringForKey:Preference_Key_General_ChatPort];
    
    [AMCoreData shareInstance].mySelf = mySelf;
}

-(void)writeSystemConfig
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    AMSystemConfig* config = [[AMSystemConfig alloc] init];
    
    config.artsmeshAddr = [defaults stringForKey:Preference_Key_General_GlobalServerAddr];
    config.artsmeshPort =  [defaults stringForKey:Preference_Key_General_GlobalServerPort];
    config.localServerIp = @"";
    config.localServerPort = [defaults stringForKey:Preference_Key_General_LocalServerPort];
    config.remoteHeartbeatInterval = @"2";
    config.localHeartbeatInterval = @"2";
    config.remoteHeartbeatRecvTimeout = @"5";
    config.localHeartbeatRecvTimeout = @"2";
    config.serverHeartbeatTimeout = @"30";
    config.maxHeartbeatFailureCount = @"5";
    config.stunServerAddr = [defaults stringForKey:Preference_Key_General_StunServerAddr];
    config.stunServerPort = [defaults stringForKey:Preference_Key_General_StunServerPort];
    config.internalChatPort = [defaults stringForKey:Preference_Key_General_ChatPort];
    config.useIpv6 =  [defaults stringForKey:Preference_Key_General_UseIpv6];

    [AMCoreData shareInstance].systemConfig = config;
}

-(void)writeGroupProfile
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    AMLiveGroup* localGroup = [[AMLiveGroup alloc] init];
    localGroup.groupId = [AMCommonTools creatUUID];
    localGroup.groupName = [defaults stringForKey:Preference_Key_Cluster_Name];
    localGroup.description = [defaults stringForKey:Preference_Key_Cluster_Description];;
    localGroup.fullName = [defaults stringForKey:Preference_Key_Cluster_FullName];
    localGroup.location = [defaults stringForKey:Preference_Key_Cluster_Location];
    localGroup.longitude = @"";
    localGroup.latitude = @"";
    localGroup.project = [defaults stringForKey:Preference_Key_Cluster_Project];
    localGroup.password = @"";

    [AMCoreData shareInstance].myLocalLiveGroup= localGroup;
}


@end
