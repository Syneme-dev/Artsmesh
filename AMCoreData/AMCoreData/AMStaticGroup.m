//
//  AMStaticGroup.m
//  AMCoreData
//
//  Created by Wei Wang on 7/17/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMStaticGroup.h"

@implementation AMStaticGroup
@synthesize description;

+(AMStaticGroup*)staticGroupFromDict:(NSDictionary*)dict
{
    AMStaticGroup* staticGroup = [[AMStaticGroup alloc] init];
    
    staticGroup.g_id = dict[@"id"];
    
    staticGroup.url = [self convertNullToEmpty:dict[@"url"]];
    staticGroup.nickname = [self convertNullToEmpty:dict[@"nickname"]];
    staticGroup.fullname = [self convertNullToEmpty:dict[@"fullname"]];
    staticGroup.admin_count = [self convertNullToEmpty:dict[@"admin_count"]];
    staticGroup.member_count = [self convertNullToEmpty:dict[@"member_count"]];
    staticGroup.original_logo = [self convertNullToEmpty:dict[@"original_logo"]];
    staticGroup.homepage_logo = [self convertNullToEmpty:dict[@"homepage_logo"]];
    staticGroup.stream_logo = [self convertNullToEmpty:dict[@"stream_logo"]];
    staticGroup.mini_logo = [self convertNullToEmpty:dict[@"mini_logo"]];
    staticGroup.homepage = [self convertNullToEmpty:dict[@"homepage"]];
    staticGroup.description = [self convertNullToEmpty:dict[@"description"]];
    staticGroup.location = [self convertNullToEmpty:dict[@"location"]];
    staticGroup.created = [self convertNullToEmpty:dict[@"created"]];
    staticGroup.modified = [self convertNullToEmpty:dict[@"modified"]];
    
    return staticGroup;
}

+(NSString*)convertNullToEmpty:(id)val;
{
    return [val isKindOfClass:[NSString class]] ? val : @"";
}

@end
