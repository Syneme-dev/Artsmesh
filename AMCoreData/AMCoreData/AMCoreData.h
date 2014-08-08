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

#define AM_MYSELF_CHANGING_LOCAL        @"AM_MYSELF_CHANGING_LOCAL"
#define AM_MYSELF_CHANGING_REMOTE       @"AM_MYSELF_CHANGING_REMOTE"
#define AM_MYSELF_CHANGED_LOCAL         @"AM_MYSELF_CHANDED_LOCAL"
#define AM_MYSELF_CHANGED_REMOTE        @"AM_MYSELF_CHANDED_REMOTE"
#define AM_MYGROUP_CHANGING_LOCAL       @"AM_MYGROUP_CHANGING_LOCAL"
#define AM_MYGROUP_CHANGING_REMOTE      @"AM_MYGROUP_CHANGING_REMOTE"
#define AM_MYGROUP_CHANGED_LOCAL        @"AM_MYGROUP_CHANDED_LOCAL"
#define AM_MYGROUP_CHANGED_REMOTE       @"AM_MYGROUP_CHANDED_REMOTE"

#define AM_LIVE_GROUP_CHANDED           @"AM_LIVE_GROUP_CHANDED"
#define AM_REMOTE_LIVE_GROUP_CHANDED    @"AM_REMOTE_LIVE_GROUP_CHANDED"
#define AM_STATIC_GROUP_CHANGED         @"AM_STATIC_GROUP_CHANGED"
#define AM_SYSTEM_CONFIG_CHANGED        @"AM_SYSTEM_CONFIG_CHANGED"
#define AM_MERGED_GROUPID_CHANGED       @"AM_MERGED_GROUPID_CHANGED"
#define AM_MYSTATIC_GROUPS_CHANGED      @"AM_MYSTATIC_GROUPS_CHANGED"

@interface AMCoreData : NSObject

@property AMLiveUser* mySelf;
@property AMLiveGroup* myLocalLiveGroup;
@property NSString* mergedGroupId;
@property NSArray* remoteLiveGroups;
@property NSArray* staticGroups;
@property AMSystemConfig* systemConfig;
@property NSArray* myStaticGroups;


+(AMCoreData*)shareInstance;
-(void)broadcastChanges:(NSString*)notificationName;

@end




