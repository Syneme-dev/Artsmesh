//
//  AMETCDGroupTTLOperation.h
//  AMMesher
//
//  Created by 王 为 on 4/8/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDOperation.h"

@interface AMETCDGroupTTLOperation : AMETCDOperation

@property NSString* fullGroupName;
@property int ttl;

-(id)initWithParameter:(NSString*)ip
            port:(NSString*)port
             fullGroupName:(NSString*)fullGroupName
                   ttl:(int)ttl;

@end
