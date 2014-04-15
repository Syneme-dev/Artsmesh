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
                    Preference_ETCD_InstanceName, Preference_Key_ETCD_InstanceName,
                    Preference_ETCD_ClientPort, Preference_key_ETCD_ClientPort,
                    Preference_ETCD_ServerPort, Preference_Key_ETCD_ServerPort,
                    Preference_ETCD_ClientIP, Preference_Key_ETCD_ClientIP,
                    Preference_ETCD_ServerIP, Preference_Key_ETCD_ServerIP,
                    Preference_ETCD_HeartbeatTimeout, Preference_Key_ETCD_HeartbeatTimeout,
                    Preference_ETCD_ElectionTimeout, Preference_Key_ETCD_ElectionTimeout,
                    Preference_User_Domain, Preference_Key_User_Domain,
                    Preference_User_Description, Preference_Key_User_Description,
                    Preference_User_Status, Preference_Key_User_Status,
                    Preference_ETCD_ArtsmeshIO_IP, Preference_Key_ETCD_ArtsmeshIOIP,
                    Preference_ETCD_ArtsmeshIO_Port, Preference_Key_ETCD_ArtsmeshIOPort,

                    Preference_ETCD_MaxNode, Preference_Key_ETCD_MaxNode,
                    Preference_ETCD_User_TTL, Preference_Key_ETCD_User_TTL,

                    Preference_User_Project, Preference_Key_User_Project,
                    Preference_User_Location, Preference_Key_User_Location,
                    Preference_User_NickName, Preference_Key_User_NickName,
                    Preference_User_FullName, Preference_Key_User_FullName,

                    nil];

    [[NSUserDefaults standardUserDefaults] registerDefaults:registrationDomainDefaultsValues];

}


@end
