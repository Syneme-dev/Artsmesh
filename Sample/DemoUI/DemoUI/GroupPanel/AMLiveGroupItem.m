//
//  AMLiveGroupItem.m
//  DemoUI
//
//  Created by 王为 on 19/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMLiveGroupItem.h"
#import "AMLiveUserItem.h"

@implementation AMLiveGroupItem

+(AMLiveGroupItem *)itemFromLiveGroup:(AMLiveGroup *)group
{
    if (group == nil) {
        return nil;
    }
    
    AMLiveGroupItem *root = [[AMLiveGroupItem alloc] init];
    root.title = group.groupName;
    root.groupData = group;
    
    
    NSMutableArray *subItems = [[NSMutableArray alloc] init];
    
    for (AMLiveUser *user in group.users) {
        AMLiveUserItem *userItem = [AMLiveUserItem itemFromLiveUser:user];
        [subItems addObject:userItem];
    }
    
    for (AMLiveGroup* subGroup in group.subGroups) {
        AMLiveGroupItem *subGrougItem = [AMLiveGroupItem itemFromLiveGroup:subGroup];
        [subItems addObject:subGrougItem];
    }
    
    root.subItems = subItems;
    
    return root;
}


-(BOOL)isBroadcasting
{
    return [self.groupData broadcasting];
}

@end
