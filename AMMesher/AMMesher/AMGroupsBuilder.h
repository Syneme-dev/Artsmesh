//
//  AMGroupsBuilder.h
//
//  Created by lattesir on 5/27/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMGroup.h"

@interface AMGroupsBuilder : NSObject

- (void)addUser:(AMUser *)user;
- (NSArray *)groups;

@end
