//
//  AMStaticUser.m
//  AMCoreData
//
//  Created by Wei Wang on 7/17/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMStaticUser.h"

@implementation AMStaticUser
@synthesize description;

+(AMStaticUser*)staticUserFromDict:(NSDictionary*)dict
{
    AMStaticUser* staticUser = [[AMStaticUser alloc] init];
    staticUser.u_id = dict[@"id"];

    staticUser.name = [self convertNullToEmpty:dict[@"name"]];
    staticUser.screen_name = [self convertNullToEmpty:dict[@"screen_name"]];
    staticUser.location = [self convertNullToEmpty:dict[@"location"]];
    staticUser.description = [self convertNullToEmpty:dict[@"description"]];
    staticUser.profile_image_url = [self convertNullToEmpty:dict[@"profile_image_url"]];
    staticUser.profile_image_url_https = [self convertNullToEmpty:dict[@"profile_image_url_https"]];
    staticUser.profile_image_url_profile_size = [self convertNullToEmpty:dict[@"profile_image_url_profile_size"]];
    staticUser.profile_image_url_original = [self convertNullToEmpty:dict[@"profile_image_url_original"]];
    staticUser.groups_count = [self convertNullToEmpty:dict[@"groups_count"]];
    staticUser.linkcolor = [self convertNullToEmpty:dict[@"linkcolor"]];
    staticUser.description = [self convertNullToEmpty:dict[@"description"]];
    staticUser.location = [self convertNullToEmpty:dict[@"location"]];
    staticUser.backgroundcolor = [self convertNullToEmpty:dict[@"backgroundcolor"]];
    staticUser.url = [self convertNullToEmpty:dict[@"url"]];
    staticUser.isProtected = [self convertNullToEmpty:dict[@"isProtected"]];
    staticUser.followers_count = [self convertNullToEmpty:dict[@"followers_count"]];
    staticUser.create_at = [self convertNullToEmpty:dict[@"create_at"]];
    staticUser.favourites_count = [self convertNullToEmpty:dict[@"favourites_count"]];
    staticUser.utl_offset = [self convertNullToEmpty:dict[@"utl_offset"]];
    staticUser.time_zone = [self convertNullToEmpty:dict[@"time_zone"]];
    staticUser.statuses_count = [self convertNullToEmpty:dict[@"statuses_count"]];
    staticUser.following = [self convertNullToEmpty:dict[@"following"]];
    staticUser.statusnet_blocking = [self convertNullToEmpty:dict[@"statusnet_blocking"]];
    staticUser.notifications = [self convertNullToEmpty:dict[@"notifications"]];
    staticUser.statusnet_profile_url = [self convertNullToEmpty:dict[@"statusnet_profile_url"]];

    return staticUser;
}

+(NSString*)convertNullToEmpty:(id)val;
{
    return [val isKindOfClass:[NSString class]] ? val : @"";
}



@end
