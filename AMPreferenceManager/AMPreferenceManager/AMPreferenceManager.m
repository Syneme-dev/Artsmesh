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
             Preference_ETCDInstanceName,Preference_Key_ETCDInstanceName,
             Preference_ETCDClientPort, Preference_key_ETCDClientPort,
             Preference_ETCDServerPort, Preference_Key_ETCDServerPort,
             Preference_ETCDClientIP, Preference_Key_ETCDClientIP,
             Preference_ETCDServerIP, Preference_Key_ETCDServerIP,
             Preference_ETCD_HeartbeatTimeout, Preference_Key_ETCD_HeartbeatTimeout,
             Preference_ETCD_ElectionTimeout, Preference_Key_ETCD_ElectionTimeout,
             nil];

    [[NSUserDefaults standardUserDefaults] registerDefaults:registrationDomainDefaultsValues];

}


@end
