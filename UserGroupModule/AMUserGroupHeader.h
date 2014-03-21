//
//  AMUserGroupHeader.h
//  UserGroupModule
//
//  Created by 王 为 on 3/20/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

enum AMMesherCtrlRequestType
{
    Register,
    Unregister,
    HeartBeat,
    Merge,
    UpdateGroupList,
    UpdateUserList,
};

@interface AMMesherCtrlRequest : NSObject
@property enum AMMesherCtrlRequestType* requestType;

@end

