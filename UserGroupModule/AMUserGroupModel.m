//
//  AMUeserGroupModel.m
//  UserGroupModule
//
//  Created by Wei Wang on 3/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserGroupModel.h"

@implementation AMUserGroupModel

-(id)init
{
    if(self = [super init])
    {
        self.myself = [[NSMutableDictionary alloc] init];
        self.groups = [[NSMutableDictionary alloc] init];
        self.users = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

@end
