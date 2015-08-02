//
//  AMCoreData.h
//  AMCoreData
//
//  Created by Wei Wang on 7/17/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMLiveGroup.h"
#import "AMLiveUser.h"
#import "AMStaticGroup.h"
#import "AMStaticUser.h"
#import "AMSystemConfig.h"

#define AM_MYSELF_CHANGED_LOCAL         @"AM_MYSELF_CHANDED_LOCAL"
#define AM_MYSELF_CHANGED_REMOTE        @"AM_MYSELF_CHANDED_REMOTE"
#define AM_LIVE_GROUP_CHANDED           @"AM_LIVE_GROUP_CHANDED"

#define AM_LOCAL_SERVER_CONNECTION_ERROR @"AM_LOCAL_SERVER_CONNECTION_ERROR"

#define AM_STATIC_GROUP_CHANGED         @"AM_STATIC_GROUP_CHANGED"
#define AM_SYSTEM_CONFIG_CHANGED        @"AM_SYSTEM_CONFIG_CHANGED"
#define AM_MYSTATIC_GROUPS_CHANGED      @"AM_MYSTATIC_GROUPS_CHANGED"


#define AM_NOTIFICATION_LOCALGROUP_CHANGED @"AM_NOTIFICATION_LOCALGROUP_CHANGED"
#define AM_GOOGLE_ACCOUNT_CHANGED @"AM_GOOGLE_ACCOUNT_CHANGED"

@interface AMCoreData : NSObject

@property AMLiveUser* mySelf;
@property AMLiveGroup* myLocalLiveGroup;
//@property NSString* mergedGroupId;
@property NSArray* remoteLiveGroups;
@property NSArray* staticGroups;
@property AMSystemConfig* systemConfig;
@property NSArray* myStaticGroups;


+(AMCoreData*)shareInstance;
-(void)broadcastChanges:(NSString*)notificationName;

-(AMLiveGroup*)mergedGroup;
-(NSArray *)myMergedGroupsInFlat;

+(BOOL)isUser:(AMLiveUser *)user inGroup:(AMLiveGroup *)group;

@end




