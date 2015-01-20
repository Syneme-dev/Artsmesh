//
//  AMLiveUserItem.m
//  DemoUI
//
//  Created by 王为 on 19/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMLiveUserItem.h"

@implementation AMLiveUserItem

+(AMLiveUserItem *)itemFromLiveUser:(AMLiveUser *)user
{
    AMLiveUserItem *item = [[AMLiveUserItem alloc] init];
    item.title = user.nickName;
    item.userData = user;
    item.subItems = nil;
    
    return item;
}

-(BOOL)isLeader
{
    return [self.userData isLeader];
}

-(BOOL)isRunningOSC
{
    return [self.userData oscServer];
}

-(BOOL)hideBar
{
    return NO;
}

-(NSImage *)barImage
{
    if(self.userData.isOnline){
        return [NSImage imageNamed:@"user_online"];
    }else{
        return [NSImage imageNamed:@"user_offline"];
    }
}


@end
