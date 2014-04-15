//
//  AMETCDAddUserOperation.h
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDOperation.h"

@interface AMETCDAddUserOperation : AMETCDOperation

@property NSString* fullUserName;
@property NSString* fullGroupName;
@property int ttl;

-(id)initWithParameter:(NSString*)ip
                  port:(NSString*)port
          fullUserName:(NSString*)fullUserName
         fullGroupName:(NSString*)fullGroupName
                   ttl:(int)ttl;

@end
