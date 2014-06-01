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
             Preference_General_ChatPort,        Preference_Key_General_ChatPort,
             Preference_User_Domain,             Preference_Key_User_Domain,
             Preference_User_Description,        Preference_Key_User_Description,
             Preference_User_Project,            Preference_Key_User_Project,
             Preference_User_Location,           Preference_Key_User_Location,
             Preference_User_NickName,           Preference_Key_User_NickName,
             Preference_User_FullName,           Preference_Key_User_FullName,
             Preference_User_PrivateIp,          Preference_Key_User_PrivateIp,
            nil];

    [[NSUserDefaults standardUserDefaults] registerDefaults:registrationDomainDefaultsValues];

}


@end
