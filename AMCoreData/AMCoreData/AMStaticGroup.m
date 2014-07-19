//
//  AMStaticGroup.m
//  AMCoreData
//
//  Created by Wei Wang on 7/17/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMStaticGroup.h"

@implementation AMStaticGroup

+(AMStaticGroup*)staticGroupFromDict:(NSDictionary*)dict
{
    AMStaticGroup* staticGroup = [[AMStaticGroup alloc] init];
    
    staticGroup.g_id = dict[@"id"];
    staticGroup.url = dict[@"url"];
    staticGroup.nickname =dict[@"nickname"];
    staticGroup.fullname =dict[@"fullname"];
    staticGroup.admin_count =dict[@"admin_count"];
    staticGroup.member_count =dict[@"member_count"];
    staticGroup.original_logo =dict[@"original_logo"];
    staticGroup.homepage_logo =dict[@"homepage_logo"];
    staticGroup.stream_logo =dict[@"stream_logo"];
    staticGroup.mini_logo =dict[@"mini_logo"];
    staticGroup.homepage =dict[@"homepage"];
    staticGroup.description =dict[@"description"];
    staticGroup.location =dict[@"location"];
    staticGroup.created =dict[@"created"];
    staticGroup.modified =dict[@"modified"];
    
    return staticGroup;
}

@end
