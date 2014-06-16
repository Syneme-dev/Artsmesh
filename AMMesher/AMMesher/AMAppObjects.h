//
//  AMAppObjects.h
//  AMMesher
//
//  Created by lattesir on 6/15/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const AMClusterNameKey;   // NSString *
extern NSString * const AMClusterIdKey;     // NSString *
extern NSString * const AMLocalUsersKey;    // NSArray *
extern NSString * const AMMyselfKey;        // AMUser *
extern NSString * const AMMergedGroupIdKey; // NSString *
extern NSString * const AMRemoteGroupsKey;  // NSDictionary *

@interface AMAppObjects : NSObject

+ (id)appObjects;


@end
