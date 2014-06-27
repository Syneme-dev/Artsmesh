//
//  AMGroup.h
//
//  Created by lattesir on 5/27/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMAppObjects.h"

@interface AMGroup : NSObject

@property(nonatomic) NSString *groupId;
@property(nonatomic) NSString *groupName;
@property(nonatomic) NSArray *users;
@property NSString* password;
@property NSString* description;
@property NSString* leaderId;
@property NSString* leaderName;


+ (NSString*) createGroupId;

@end
