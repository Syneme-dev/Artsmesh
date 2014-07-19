//
//  AMStaticUser.m
//  AMCoreData
//
//  Created by Wei Wang on 7/17/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMStaticUser.h"

@implementation AMStaticUser

+(AMStaticUser*)staticUserFromDict:(NSDictionary*)dict
{
    AMStaticUser* staticUser = [[AMStaticUser alloc] init];
    
    staticUser.u_id = dict[@"id"];
    staticUser.name = dict[@"name"];
    staticUser.screen_name =dict[@"screen_name"];
    staticUser.location =dict[@"location"];
    staticUser.description =dict[@"description"];
    staticUser.profile_image_url =dict[@"profile_image_url"];
    staticUser.profile_image_url_https =dict[@"profile_image_url_https"];
    staticUser.profile_image_url_profile_size =dict[@"profile_image_url_profile_size"];
    staticUser.profile_image_url_original =dict[@"profile_image_url_original"];
    staticUser.groups_count =dict[@"groups_count"];
    staticUser.linkcolor =dict[@"linkcolor"];
    staticUser.description =dict[@"description"];
    staticUser.location =dict[@"location"];
    staticUser.backgroundcolor =dict[@"backgroundcolor"];
    staticUser.url =dict[@"url"];
    staticUser.isProtected =dict[@"isProtected"];
    staticUser.followers_count =dict[@"followers_count"];
    staticUser.create_at =dict[@"create_at"];
    staticUser.favourites_count =dict[@"favourites_count"];
    staticUser.utl_offset =dict[@"utl_offset"];
    staticUser.time_zone =dict[@"time_zone"];
    staticUser.statuses_count =dict[@"statuses_count"];
    staticUser.following =dict[@"following"];
    staticUser.statusnet_blocking =dict[@"statusnet_blocking"];
    staticUser.notifications =dict[@"notifications"];
    staticUser.statusnet_profile_url =dict[@"statusnet_profile_url"];

    return staticUser;
}



@end
