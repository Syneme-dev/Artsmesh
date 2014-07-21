//
//  AMStaticGroup.h
//  AMCoreData
//
//  Created by Wei Wang on 7/17/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMStaticGroup : NSObject

@property (nonatomic, strong) NSString* g_id;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSString* nickname;
@property (nonatomic, strong) NSString* fullname;
@property (nonatomic, strong) NSString* admin_count;
@property (nonatomic, strong) NSString* member_count;
@property (nonatomic, strong) NSString* original_logo;
@property (nonatomic, strong) NSString* homepage_logo;
@property (nonatomic, strong) NSString* stream_logo;
@property (nonatomic, strong) NSString* mini_logo;
@property (nonatomic, strong) NSString* homepage;
@property (nonatomic, strong) NSString* description;
@property (nonatomic, strong) NSString* location;
@property (nonatomic, strong) NSString* created;
@property (nonatomic, strong) NSString* modified;

@property (nonatomic, strong) NSArray* users;

+(AMStaticGroup*)staticGroupFromDict:(NSDictionary*)dict;

@end
