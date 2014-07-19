//
//  AMStaticUser.h
//  AMCoreData
//
//  Created by Wei Wang on 7/17/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMStaticUser : NSObject

@property NSString* u_id;
@property NSString* name;
@property NSString* screen_name;
@property NSString* location;
@property NSString* description;
@property NSString* profile_image_url;
@property NSString* profile_image_url_https;
@property NSString* profile_image_url_profile_size;
@property NSString* profile_image_url_original;
@property NSString* groups_count;
@property NSString* linkcolor;
@property NSString* backgroundcolor;
@property NSString* url;
@property NSString* isProtected;
@property NSString* followers_count;
@property NSString* create_at;
@property NSString* favourites_count;
@property NSString* utl_offset;
@property NSString* time_zone;
@property NSString* statuses_count;
@property NSString* following;
@property NSString* statusnet_blocking;
@property NSString* notifications;
@property NSString* statusnet_profile_url;

+(AMStaticUser*)staticUserFromDict:(NSDictionary*)dict;

@end
