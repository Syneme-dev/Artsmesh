//
//  AMPreferenceManager.m
//  AMPreferenceManager
//
//  Created by Sky JIA on 12/30/13.
//  Copyright (c) 2013 Artsmesh. All rights reserved.
//


#import "AMPreferenceManager.h"



@implementation AMPreferenceManager

+ (AMPreferenceManager *)defaultShared {
    return nil;
}

+ (NSUserDefaults *)instance {
    return [NSUserDefaults standardUserDefaults];
}




+ (void)registerPreference {
    NSDictionary *registrationDomainDefaultsValues =
            [NSDictionary dictionaryWithObjectsAndKeys:
//             Preference_General_MachineName,     Preference_Key_General_MachineName,
//             Preference_General_PrivateIP,       Preference_Key_General_PrivateIP,
//             Preference_General_PublicIP,        Preference_Key_General_PublicIP,
//             Preference_General_ChatPort,        Preference_Key_General_ChatPort,
//             Preference_General_ControlPort,     Preference_Key_General_ControlPort,
//             Preference_ETCD_ServerPort,         Preference_Key_ETCD_ServerPort,
//             Preference_ETCD_ClientPort,         Preference_key_ETCD_ClientPort,
//             Preference_ETCD_HeartbeatTimeout,   Preference_Key_ETCD_HeartbeatTimeout,
//             Preference_ETCD_ElectionTimeout,    Preference_Key_ETCD_ElectionTimeout,
//             Preference_ETCD_UserTTLTimeout,     Preference_Key_ETCD_UserTTLTimeout,
//             Preference_ETCD_ArtsmeshIO_IP,      Preference_Key_ETCD_ArtsmeshIOIP,
//             Preference_ETCD_ArtsmeshIO_Port,    Preference_Key_ETCD_ArtsmeshIOPort,
//             Preference_ETCD_MaxNode,            Preference_Key_ETCD_MaxNode,
//             Preference_User_Domain,             Preference_Key_User_Domain,
//             Preference_User_Description,        Preference_Key_User_Description,
//             Preference_User_Status,             Preference_Key_User_Status,
//             Preference_User_Project,            Preference_Key_User_Project,
//             Preference_User_Location,           Preference_Key_User_Location,
//             Preference_User_NickName,           Preference_Key_User_NickName,
//             Preference_User_FullName,           Preference_Key_User_FullName,
            nil];

    [[NSUserDefaults standardUserDefaults] registerDefaults:registrationDomainDefaultsValues];

}


@end
