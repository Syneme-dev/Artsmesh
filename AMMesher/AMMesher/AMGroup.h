//
//  AMGroup.h
//
//  Created by lattesir on 5/27/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMUser.h"

@interface AMGroup : NSObject

@property(nonatomic) NSString *groupName;
@property(nonatomic) NSArray *users;

@end
