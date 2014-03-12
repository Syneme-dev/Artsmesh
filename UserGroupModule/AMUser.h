//
//  AMUser.h
//  UserGroupModule
//
//  Created by Wei Wang on 3/12/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMUser : NSObject

@property NSString* name;
@property NSMutableArray* children;

- (NSInteger)numberOfChildren;
- (AMUser *)childAtIndex:(NSUInteger)n;

@end
