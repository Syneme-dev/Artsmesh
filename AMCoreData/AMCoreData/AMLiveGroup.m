//
//  AMLiveGroup.m
//  AMCoreData
//
//  Created by Wei Wang on 7/17/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMLiveGroup.h"

@implementation AMLiveGroup

-(NSMutableDictionary*)dictWithoutUsers
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    dict[@"groupId"] = self.groupId;
    dict[@"groupName"] = self.groupName;
    dict[@"description"] = self.description;
    dict[@"leaderId"] = self.leaderId;
    return dict;
}

+(id)AMGroupFromDict:(NSDictionary*)dict
{
    AMLiveGroup* group = [[AMLiveGroup alloc] init];
    group.groupId = dict[@"GroupId"];
    group.groupName = dict[@"GroupName"];
    group.description = dict[@"Description"];
    group.leaderId = dict[@"LeaderId"];
    group.password = @"";
    return group;
}

@end
