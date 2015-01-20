//
//  AMLiveGroupItem.m
//  DemoUI
//
//  Created by 王为 on 19/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMGroupItem.h"
#import "AMLiveUserItem.h"

@implementation AMGroupItem

+(AMGroupItem *)itemFromLiveGroup:(AMLiveGroup *)group
{
    if (group == nil) {
        return nil;
    }
    
    AMGroupItem *root = [[AMGroupItem alloc] init];
    root.title = group.groupName;
    root.groupData = group;
    
    
    NSMutableArray *subItems = [[NSMutableArray alloc] init];
    
    for (AMLiveUser *user in group.users) {
        AMLiveUserItem *userItem = [AMLiveUserItem itemFromLiveUser:user];
        [subItems addObject:userItem];
    }
    
    for (AMLiveGroup* subGroup in group.subGroups) {
        AMGroupItem *subGrougItem = [AMGroupItem itemFromLiveGroup:subGroup];
        [subItems addObject:subGrougItem];
    }
    
    root.subItems = subItems;
    
    return root;
}


-(BOOL)isBroadcasting
{
    return [self.groupData broadcasting];
}

-(BOOL)canLeave
{
    AMLiveGroup *localGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    if ([localGroup.groupId isEqualToString:self.groupData.groupId]) {
        return NO;
    }
    
    if ( ![self isInRootGroups]) {
        return NO;
    }
    
    AMLiveUser *mySelf = [AMCoreData shareInstance].mySelf;
    if ([AMCoreData isUser:mySelf inGroup:self.groupData]) {
        return YES;
    }
    
    return NO;
}


-(BOOL)canMerge
{
    AMLiveGroup *localGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    if ([localGroup.groupId isEqualToString:self.groupData.groupId]) {
        return NO;
    }
    
    if (![self isInRootGroups]) {
        return NO;
    }
    
    AMLiveUser *mySelf = [AMCoreData shareInstance].mySelf;
    if ([AMCoreData isUser:mySelf inGroup:self.groupData]) {
        return NO;
    }
    
    return YES;
}


-(BOOL)isInRootGroups
{
    BOOL find = NO;
    for (AMLiveGroup *liveGroup in [AMCoreData shareInstance].remoteLiveGroups) {
        if ([liveGroup.groupId isEqualToString:self.groupData.groupId]) {
            find = YES;
            break;
        }
    }
    
    if (find == NO) {
        return NO;
    }
    
    return YES;
}


@end
