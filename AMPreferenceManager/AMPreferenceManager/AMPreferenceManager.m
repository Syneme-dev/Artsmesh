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


@implementation AMPanelLocation
@end


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
    NSDictionary *registrationDomainDefaultsValues =
            [NSDictionary dictionaryWithObjectsAndKeys:
             Preference_General_ChatPort,        Preference_Key_General_ChatPort,
             Preference_User_Affiliation,        Preference_Key_User_Affiliation,
             Preference_User_Description,        Preference_Key_User_Description,
             Preference_User_Location,           Preference_Key_User_Location,
             Preference_User_NickName,           Preference_Key_User_NickName,
             Preference_User_FullName,           Preference_Key_User_FullName,
             Preference_User_PrivateIp,          Preference_Key_User_PrivateIp,
             Preference_User_Ipv6Address,        Preference_Key_User_Ipv6Address,
             Preference_General_StunServerAddr,  Preference_Key_General_StunServerAddr,
             Preference_General_StunServerPort,  Preference_Key_General_StunServerPort,
             
             @"NO",     Preference_Key_General_MeshUseIpv6,
             @"NO",     Preference_Key_General_HeartbeatUseIpv6,
             
             Preference_General_GlobalServerAddrIpv4, Preference_Key_General_GlobalServerAddrIpv4,
             Preference_General_GlobalServerAddrIpv6, Preference_Key_General_GlobalServerAddrIpv6,
             Preference_General_GlobalServerPort,Preference_Key_General_GlobalServerPort,
             
             Preference_General_LocalServerPort, Preference_Key_General_LocalServerPort,
             openedPanel,UserData_Key_OpenedPanel,
             Preference_Cluster_Name,            Preference_Key_Cluster_Name,
             Preference_Cluster_Description,     Preference_Key_Cluster_Description,
             Preference_Cluster_FullName,        Preference_Key_Cluster_FullName,
             Preference_Cluster_Location,        Preference_Key_Cluster_Location,
             Preference_Cluster_Project,         Preference_Key_Cluster_Project,
             @"this is project description",     Preference_Key_Cluster_Project_Descrition,
             @"http://www.artsmesh.io",          Preference_Key_Cluster_HomePage,
             Preference_StatusNet_URL,           Preference_Key_StatusNet_URL,
             Preference_Cluster_Latitude,        Preference_Key_Cluster_Latitude,
             Preference_Cluster_Longitude,       Preference_Key_Cluster_Longitude,
             @"DISCOVER", Preference_Key_Cluster_LSConfig,
             @"2", Preference_Jack_RouterVirtualChanns,
             @"2", Preference_Jack_VirtualInChannels,
             @"2", Preference_Jack_VirtualOutChannels,
             @"22242", Preference_OSC_Server_Port,
             @"30", Preference_OSC_Server_Timeout,
             @"50", Preference_OSC_Server_MaxGroups,
             @"50", Preference_OSC_Server_MaxUsers,
             @"localhost", Preference_OSC_Client_ServerAddr,
             @"22242", Preference_OSC_Client_ServerPort,
             @"22243", Preference_OSC_Client_RemotePort,
             @"22244", Preference_OSC_Client_RxPort,
             @"22245", Preference_OSC_Client_TxPort,
             @"default", Preference_OSC_Client_UserName,
             @"default", Preference_OSC_Client_UserPwd,
             @"default", Preference_OSC_Client_GroupName,
             @"default", Preference_OSC_Client_GroupPwd,
             @"localhost", Preference_OSC_Client_MonitorAddr,
             @"22230", Preference_OSC_Client_MonitorPort,
             @"SERVER", Preference_Jacktrip_Role,
             @"2", Preference_Jacktrip_ChannelCount,
             @"4",Preference_Jacktrip_QBL,
             @"16", Preference_Jacktrip_BRR,
             @"1", Preference_Jacktrip_PR,
             @"NO", Preference_Jacktrip_ZeroUnderRun,
             @"NO", Preference_Jacktrip_Loopback,
             @"NO", Preference_Jacktrip_Jamlink,
             @"NO", Preference_Jacktrip_UseIpv6,
             @"SERVER", Preference_iPerf_Role,
             @"YES",    Preference_iPerf_UseUDP,
             @"5001",   Preference_iPerf_Port,
             @"10",     Preference_iPerf_Bandwith,
             @"10",     Preference_iPerf_BufferLen,
             @"NO",     Preference_iPerf_Tradeoff,
             @"NO",     Preference_iPerf_Dualtest,
             @"YES",Preference_Key_General_TopControlBar,
             @"NO", Preference_Key_General_UseOSCForChat,
             Preference_ffmpeg_Video_In_Device, Preference_Key_ffmpeg_Video_In_Device,
             Preference_ffmpeg_Video_In_Size, Preference_Key_ffmpeg_Video_In_Size,
             Preference_ffmpeg_Video_Out_Size, Preference_Key_ffmpeg_Video_Out_Size,
             Preference_ffmpeg_Video_Format, Preference_Key_ffmpeg_Video_Format,
             Preference_ffmpeg_Video_Frame_Rate, Preference_Key_ffmpeg_Video_Frame_Rate,
             Preference_ffmpeg_Video_Bit_Rate, Preference_Key_ffmpeg_Video_Bit_Rate,
             Preference_ffmpeg_Audio_In_Device, Preference_Key_ffmpeg_Audio_In_Device,
             Preference_ffmpeg_Audio_Format, Preference_Key_ffmpeg_Audio_Format,
             Preference_ffmpeg_Audio_Sample_Rate, Preference_Key_ffmpeg_Audio_Sample_Rate,
             Preference_ffmpeg_Audio_Bit_Rate, Preference_Key_ffmpeg_Audio_Bit_Rate,
             Preference_ffmpeg_Base_Url, Preference_Key_ffmpeg_Base_Url,
             Preference_ffmpeg_Base6_Url,
                 Preference_Key_ffmpeg_Base6_Url,
             Preference_ffmpeg_Stream_Key,
                 Preference_Key_ffmpeg_Stream_Key,
             Preference_ffmpeg_Cur_Stream, Preference_Key_ffmpeg_Cur_Stream, Preference_ffmpeg_Video_Use_Custom_In,Preference_Key_ffmpeg_Video_Use_Custom_In, Preference_ffmpeg_Video_Use_Custom_Out, Preference_Key_ffmpeg_Video_Use_Custom_Out, Preference_ffmpeg_Video_In_Size_Custom_W, Preference_Key_ffmpeg_Video_In_Size_Custom_W, Preference_ffmpeg_Video_In_Size_Custom_H, Preference_Key_ffmpeg_Video_In_Size_Custom_H, Preference_ffmpeg_Video_Out_Size_Custom_W, Preference_Key_ffmpeg_Video_Out_Size_Custom_W, Preference_ffmpeg_Video_Out_Size_Custom_H, Preference_Key_ffmpeg_Video_Out_Size_Custom_H,
                 Preference_ffmpeg_Cur_P2P,
                 Preference_Key_ffmpeg_Cur_P2P,
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
    mySelf.fullName = [defaults stringForKey:Preference_Key_User_FullName];
    mySelf.domain= [defaults stringForKey:Preference_Key_User_Affiliation];
    mySelf.location = [defaults stringForKey:Preference_Key_User_Location];
    mySelf.description = [defaults stringForKey:Preference_Key_User_Description];
    mySelf.privateIp = [defaults stringForKey:Preference_Key_User_PrivateIp];
    mySelf.ipv6Address = [defaults stringForKey:Preference_Key_User_Ipv6Address];
    mySelf.publicIp = mySelf.privateIp;
    mySelf.chatPort = [defaults stringForKey:Preference_Key_General_ChatPort];
    
    [AMCoreData shareInstance].mySelf = mySelf;
}

-(void)writeSystemConfig
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    AMSystemConfig* config = [[AMSystemConfig alloc] init];
    
    config.artsmeshAddrIpv4 = [defaults stringForKey:
                               Preference_Key_General_GlobalServerAddrIpv4];
    config.artsmeshAddrIpv6 = [defaults stringForKey:
                               Preference_Key_General_GlobalServerAddrIpv6];
    config.artsmeshPort =  [defaults stringForKey:Preference_Key_General_GlobalServerPort];
    config.localServerHost = nil;
    config.localServerIps = nil;
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
    config.meshUseIpv6 =  [[defaults stringForKey:
                            Preference_Key_General_MeshUseIpv6] boolValue];
    config.heartbeatUseIpv6 = [[defaults stringForKey:
                                Preference_Key_General_HeartbeatUseIpv6] boolValue];

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
    localGroup.longitude = [defaults stringForKey:Preference_Key_Cluster_Longitude];
    localGroup.latitude = [defaults stringForKey:Preference_Key_Cluster_Latitude];
    localGroup.homePage = [defaults stringForKey:Preference_Key_Cluster_HomePage];
    localGroup.projectDescription = [defaults stringForKey:Preference_Key_Cluster_Project_Descrition];
    localGroup.project = [defaults stringForKey:Preference_Key_Cluster_Project];
    localGroup.busy = NO;
    localGroup.timezoneName = [NSTimeZone systemTimeZone].name;
    localGroup.password = @"";
    localGroup.broadcasting = NO;
    localGroup.broadcastingURL = @"";

    [AMCoreData shareInstance].myLocalLiveGroup= localGroup;
}


@end
