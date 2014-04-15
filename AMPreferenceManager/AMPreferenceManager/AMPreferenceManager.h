//
//  AMPreferenceManager.h
//  AMPreferenceManager
//
//  Created by Sky JIA on 12/30/13.
//  Copyright (c) 2013 Artsmesh. All rights reserved.
//


#define Preference_Key_ETCD_InstanceName @"Preference_Key_ETCD_InstanceName"
#define Preference_Key_ETCD_ServerPort @"Preference_Key_ETCD_ServerPort"
#define Preference_key_ETCD_ClientPort @"Preference_key_ETCD_ClientPort"
#define Preference_Key_ETCD_HeartbeatTimeout @"Preference_Key_ETCD_HeartbeatTimeout"
#define Preference_Key_ETCD_ElectionTimeout @"Preference_Key_ETCD_ElectionTimeout"

//#define Preference_Key_User_TTL_Interval    @"Preference_Key_User_TTL_Interval"
#define Preference_Key_ETCD_ArtsmeshIOIP    @"Preference_Key_ETCD_ArtsmeshIOIP"
#define Preference_Key_ETCD_ArtsmeshIOPort  @"Preference_Key_ETCD_ArtsmeshIOPort"
#define Preference_Key_ETCD_ClientIP @"Preference_Key_ETCD_ClientIP"
#define Preference_Key_ETCD_ServerIP @"Preference_Key_ETCD_ServerIP"
#define Preference_Key_ETCD_MaxNode @"Preference_Key_ETCD_MaxNode"
#define Preference_Key_ETCD_User_TTL @"Preference_Key_ETCD_User_TTL"


#define Preference_Key_User_Domain             @"Preference_Key_User_Domain"
#define Preference_Key_User_Description        @"Preference_Key_User_Description"
#define Preference_Key_User_Status             @"Preference_Key_User_Status"
#define Preference_Key_User_Project @"Preference_Key_User_Project"
#define Preference_Key_User_Location @"Preference_Key_User_Location"
#define Preference_Key_User_NickName @"Preference_Key_User_NickName"
#define Preference_Key_User_FullName @"Preference_Key_User_FullName"





#define Preference_ETCD_ClientIP @"localhost"
#define Preference_ETCD_ServerIP @"localhost"
#define Preference_ETCD_InstanceName @"MyInstanceName"
#define Preference_ETCD_ServerPort [NSNumber numberWithInteger:17001]
#define Preference_ETCD_ClientPort [NSNumber numberWithInteger:14001]
#define Preference_ETCD_HeartbeatTimeout [NSNumber numberWithInteger:50]
#define Preference_ETCD_ElectionTimeout [NSNumber numberWithInteger:250]
#define Preference_User_TTL_Interval    [NSNumber numberWithInteger:10]
#define Preference_User_Domain             @"CCOM"
#define Preference_User_Description        @"This is my description."
#define Preference_User_Status             @"Online"
#define Preference_ETCD_ArtsmeshIO_IP    @"123.124.145.254"
#define Preference_ETCD_ArtsmeshIO_Port  @"14001"

#define Preference_ETCD_MaxNode [NSNumber numberWithInteger:9]
#define Preference_ETCD_User_TTL [NSNumber numberWithInteger:15]
#define Preference_User_Project @"Synema.Asia"
#define Preference_User_Location @"BeiJing"
#define Preference_User_NickName @"NickName"
#define Preference_User_FullName @"Music Art"

#import <Foundation/Foundation.h>

@interface AMPreferenceManager : NSObject

+(AMPreferenceManager *)defaultShared;

+ (void)registerPreference;
@end
