//
//  AMPreferenceManager.h
//  AMPreferenceManager
//
//  Created by Sky JIA on 12/30/13.
//  Copyright (c) 2013 Artsmesh. All rights reserved.
//


//General
#define Preference_Key_General_MachineName          @"Preference_Key_General_MachineName"
#define Preference_Key_General_PrivateIP            @"Preference_Key_General_PrivateIP"
#define Preference_Key_General_PublicIP             @"Preference_Key_General_PublicIP"
#define Preference_Key_General_ChatPort             @"Preference_Key_General_ChatPort"
#define Preference_Key_General_ControlPort          @"Preference_Key_General_ControlPort"
#define Preference


//ETCD
#define Preference_Key_ETCD_ServerPort              @"Preference_Key_ETCD_ServerPort"
#define Preference_key_ETCD_ClientPort              @"Preference_key_ETCD_ClientPort"
#define Preference_Key_ETCD_HeartbeatTimeout        @"Preference_Key_ETCD_HeartbeatTimeout"
#define Preference_Key_ETCD_ElectionTimeout         @"Preference_Key_ETCD_ElectionTimeout"
#define Preference_Key_ETCD_ArtsmeshIOIP            @"Preference_Key_ETCD_ArtsmeshIOIP"
#define Preference_Key_ETCD_ArtsmeshIOPort          @"Preference_Key_ETCD_ArtsmeshIOPort"
#define Preference_Key_ETCD_MaxNode                 @"Preference_Key_ETCD_MaxNode"
#define Preference_Key_ETCD_UserTTLTimeout          @"Preference_Key_ETCD_UserTTLTimeout"


//UserInfo
#define Preference_Key_User_NickName            @"Preference_Key_User_NickName"
#define Preference_Key_User_Domain              @"Preference_Key_User_Domain"
#define Preference_Key_User_Location            @"Preference_Key_User_Location"
#define Preference_Key_User_FullName            @"Preference_Key_User_FullName"
#define Preference_Key_User_Description         @"Preference_Key_User_Description"
#define Preference_Key_User_Status              @"Preference_Key_User_Status"
#define Preference_Key_User_Project             @"Preference_Key_User_Project"


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
