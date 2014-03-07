//
//  AMPluginAppDelegateProtocol.h
//  AMPluginLoader
//
//  Created by xujian on 3/6/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMNotificationManager;
@class AMPreferenceManager;

@protocol AMPluginAppDelegate <NSObject>


-(AMNotificationManager *) sharedNotificationManager;
-(AMPreferenceManager *) sharedPreferenceManger;

@end
