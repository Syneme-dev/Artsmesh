//
//  AMArchiveGroupItem.m
//  DemoUI
//
//  Created by 王为 on 20/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMArchiveGroupItem.h"
#import "AMArchiveUserItem.h"

@implementation AMArchiveGroupItem

+(AMArchiveGroupItem *)itemFromArchiveGroup:(AMStaticGroup *)archiveGroup
{
    AMArchiveGroupItem *item = [[AMArchiveGroupItem alloc] init];
    item.title = archiveGroup.nickname;
    item.archiveGroupData = archiveGroup;

    NSMutableArray *subItems = [[NSMutableArray alloc] init];
    item.subItems = subItems;
    
    for (AMStaticUser *user in archiveGroup.users) {
        AMArchiveUserItem *userItem = [AMArchiveUserItem itemFromArchiveUser:user];
        [subItems addObject:userItem];
    }
    
    return item;
}

@end
