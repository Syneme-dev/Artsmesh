//
//  AMGroup.h
//
//  Created by lattesir on 5/27/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMUser.h"

@interface AMGroup : NSObject

@property(nonatomic, readonly) NSString *groupName;
@property(nonatomic, readonly) NSArray *users;

// designated initializer
- (instancetype)initWithGroupName:(NSString *)groupName;
- (void)addUser:(AMUser *)user;


// collection accessor
- (NSUInteger)countOfUsers;
- (id)objectInUsersAtIndex:(NSUInteger)index;
- (void)insertObject:(AMUser *)user inUsersAtIndex:(NSUInteger)index;
- (void)removeObjectFromUsersAtIndex:(NSUInteger)index;
- (void)replaceObjectInUsersAtIndex:(NSUInteger)index withObject:(id)user;

@end
