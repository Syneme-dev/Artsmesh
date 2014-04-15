//
//  AMPreferenceManager.h
//  AMPreferenceManager
//
//  Created by Sky JIA on 12/30/13.
//  Copyright (c) 2013 Artsmesh. All rights reserved.
//


#define Preference_Key_ETCDInstanceName @"Preference_Key_ETCDInstanceName"

#define Preference_ETCDInstanceName @"MyInstanceName"

#define Preference_Key_ETCDServerPort @"Preference_Key_ETCDServerPort"
#define Preference_key_ETCDClientPort @"Preference_key_ETCDClientPort"
#define Preference_Key_ETCD_HeartbeatTimeout @"Preference_Key_ETCD_HeartbeatTimeout"
#define Preference_Key_ETCD_ElectionTimeout @"Preference_Key_ETCD_ElectionTimeout"
#define Preference_Key_User_TTL             @"Preference_Key_User_TTL"
#define Preference_Key_User_TTL_Interval    @"Preference_Key_User_TTL_Interval"
#define Preference_Key_MyDomain             @"Preference_Key_MyDomain"
#define Preference_Key_MyDescription        @"Preference_Key_MyDescription"
#define Preference_Key_MyStatus             @"Preference_Key_MyStatus"

#define Preference_Key_ArtsmeshIO_IP    @"Preference_Key_ArtsmeshIO_IP"
#define Preference_Key_ArtsmeshIO_Port  @"Preference_Key_ArtsmeshIO_Port"


#define Preference_Key_ETCDClientIP @"Preference_Key_ETCDClientIP"

#define Preference_Key_ETCDServerIP @"Preference_Key_ETCDServerIP"

#define Preference_ETCDClientIP @"localhost"

#define Preference_ETCDServerIP @"localhost"


#define Preference_ETCDServerPort [NSNumber numberWithInteger:17001]
#define Preference_ETCDClientPort [NSNumber numberWithInteger:14001]

#define Preference_ETCD_HeartbeatTimeout [NSNumber numberWithInteger:50]
#define Preference_ETCD_ElectionTimeout [NSNumber numberWithInteger:250]

#define Preference_User_TTL             [NSNumber numberWithInteger:30]
#define Preference_User_TTL_Interval    [NSNumber numberWithInteger:10]

#define Preference_MyDomain             @"CCOM2"
#define Preference_MyDescription        @"I'm a Mac Developer"
#define Preference_MyStatus             @"Online"


#define Preference_ArtsmeshIO_IP    @"123.124.145.254"
#define Preference_ArtsmeshIO_Port  @"14001"

#import <Foundation/Foundation.h>

@interface AMPreferenceManager : NSObject

+(AMPreferenceManager *)defaultShared;

+ (void)registerPreference;
@end
