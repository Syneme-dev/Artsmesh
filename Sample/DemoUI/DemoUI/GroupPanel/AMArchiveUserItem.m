//
//  AMArchiveUserItem.m
//  DemoUI
//
//  Created by 王为 on 20/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMArchiveUserItem.h"

@implementation AMArchiveUserItem

+(AMArchiveUserItem *)itemFromArchiveUser:(AMStaticUser *)user
{
    AMArchiveUserItem *item = [[AMArchiveUserItem alloc] init];
    item.title = user.name;
    item.userData = user;
    item.subItems = nil;
    
    return item;
}

-(BOOL)hideBar
{
    return NO;
}

-(NSImage *)barImage
{
    return [NSImage imageNamed:@"user_offline"];
}

@end
