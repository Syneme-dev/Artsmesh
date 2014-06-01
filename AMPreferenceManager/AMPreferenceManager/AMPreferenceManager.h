//
//  AMPreferenceManager.h
//  AMPreferenceManager
//
//  Created by Sky JIA on 12/30/13.
//  Copyright (c) 2013 Artsmesh. All rights reserved.
//


//General
#define Preference_Key_General_UseIpv6              @"Preference_Key_General_UseIpv6"
#define Preference_Key_General_MachineName          @"Preference_Key_General_MachineName"
#define Preference_Key_General_LocalServerPort      @"Preference_Key_General_LocalServerPort"
#define Preference_Key_General_GlobalServerAddr     @"Preference_Key_General_GlobalServerAddr"
#define Preference_Key_General_GlobalServerPort     @"Preference_Key_General_GlobalServerPort"
#define Preference_Key_General_ChatPort             @"Preference_Key_General_ChatPort"
#define Preference_Key_General_StunServerAddr       @"Preference_Key_General_StunServerAddr"
#define Preference_Key_General_StunServerPort       @"Preference_Key_General_StunServerPort"

//UserInfo
#define Preference_Key_User_NickName            @"Preference_Key_User_NickName"
#define Preference_Key_User_Domain              @"Preference_Key_User_Domain"
#define Preference_Key_User_Location            @"Preference_Key_User_Location"
#define Preference_Key_User_FullName            @"Preference_Key_User_FullName"
#define Preference_Key_User_Description         @"Preference_Key_User_Description"
#define Preference_Key_User_Project             @"Preference_Key_User_Project"
#define Preference_Key_User_PrivateIp           @"Preference_Key_User_PrivateIp"

//StatusNest
#define Preference_Key_StatusNet_URL            @"Preference_Key_StatusNet_URL"
#define Preference_Key_StatusNet_UserName       @"Preference_Key_StatusNet_UserName"
#define Preference_Key_StatusNet_Password       @"Preference_Key_StatusNet_Password"

//Default Value
#define Preference_General_MachineName      @"MyComputer"
#define Preference_General_PrivateIP        @"127.0.0.1"
#define Preference_General_PublicIP         @"127.0.0.1"
#define Preference_General_ChatPort         @"9033"
#define Preference_General_ControlPort      @"9357"



#define Preference_ETCD_ServerPort          @"17001"
#define Preference_ETCD_ClientPort          @"14001"
#define Preference_ETCD_HeartbeatTimeout    @"50"
#define Preference_ETCD_ElectionTimeout     @"250"
#define Preference_ETCD_UserTTLTimeout      @"30"
#define Preference_ETCD_ArtsmeshIO_IP       @"123.124.145.254"
#define Preference_ETCD_ArtsmeshIO_Port     @"14001"
#define Preference_ETCD_MaxNode             @"9"

#define Preference_User_Domain              @"CCOM"
#define Preference_User_Description         @"This is my description."
#define Preference_User_Status              @"Online"
#define Preference_User_Project             @"Synema.Asia"
#define Preference_User_Location            @"BeiJing"
#define Preference_User_NickName            @"NickName"
#define Preference_User_FullName            @"Music Art"

#import <Foundation/Foundation.h>

@interface AMPreferenceManager : NSObject

+(AMPreferenceManager *)defaultShared;

+ (void)registerPreference;
@end
