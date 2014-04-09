//
//  AMETCDUpdateUserOperation.h
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDOperation.h"

@interface AMETCDUpdateUserOperation : AMETCDOperation

@property NSString* fullUserName;
@property NSString* fullGroupName;
@property NSDictionary* properties;

-(id)initWithParameter:(NSString*)ip
                  port:(NSString*)port
          fullUserName:(NSString*)fullUserName
         fullGroupName:(NSString*)fullGroupName
        userProperties:(NSDictionary *)properties;
@end
