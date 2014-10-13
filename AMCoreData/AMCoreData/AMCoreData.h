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

#define AMNotification_MySelfChanged                @"AMNotification_MySelfChanged"
#define AMNotification_MyClusterChanged             @"AMNotification_MyClusterChanged"
#define AMNotification_MyLiveGroupChanged           @"AMNotification_MyLiveGroupChanged"
#define AMNotification_LiveGroupListChanged         @"AMNotification_LiveGroupListChanged"
#define AMNotification_ArchievedGroupListChanged    @"AMNotification_ArchievedGroupListChanged"
#define AMNotification_Meshed                       @"AMNotification_Meshed"
#define AMNotification_Demeshed                     @"AMNotification_Demeshed"



@interface AMCoreData : NSObject

@property AMLiveUser* mySelf;
@property AMLiveGroup* myLocalLiveGroup;
@property NSArray* remoteLiveGroups;
@property NSArray* staticGroups;
@property AMSystemConfig* systemConfig;
@property NSArray* myStaticGroups;


+(AMCoreData*)shareInstance;

-(AMLiveGroup*)mergedGroup;

@end




