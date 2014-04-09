//
//  AMETCDUpdateGroupOperation.h
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDOperation.h"

@interface AMETCDUpdateGroupOperation : AMETCDOperation

@property NSString* fullGroupName;
@property NSDictionary* properties;

-(id)initWithParameter:(NSString*)ip
            port:(NSString*)port
             fullGroupName:(NSString*)fullGroupName
       groupProperties:(NSDictionary*)properties;


@end
