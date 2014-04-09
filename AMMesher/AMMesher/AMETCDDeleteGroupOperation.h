//
//  AMETCDDeleteGroupOperation.h
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDOperation.h"

@interface AMETCDDeleteGroupOperation : AMETCDOperation

@property NSString* fullGroupName;

-(id)initWithParameter:(NSString*)ip
                  port:(NSString*)port
             fullGroupName:(NSString*)fullGroupName;

@end
