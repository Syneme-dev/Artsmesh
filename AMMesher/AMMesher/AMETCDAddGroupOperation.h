//
//  AMETCDAddGroupOperation.h
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDOperation.h"

@interface AMETCDAddGroupOperation : AMETCDOperation

@property NSString* fullGroupName;
@property int ttl;

-(id)initWithParameter:(NSString*)ip
                  port:(NSString*)port
             fullGroupName:(NSString*)fullGroupName
                   ttl:(int)ttl;

@end
