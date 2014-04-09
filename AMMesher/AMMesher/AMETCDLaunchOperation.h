//
//  AMETCDLaunchOperation.h
//  AMMesher
//
//  Created by 王 为 on 4/9/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDOperation.h"

@interface AMETCDLaunchOperation : AMETCDOperation

 @property NSMutableArray*  parameters;

-(id)initWithParameter:(NSString*)ip
            clientPort:(NSString*)cp
            serverPort:(NSString*)sp
                 peers:(NSString*)peers
     heartbeatInterval:(NSString*)hbInterval
       electionTimeout:(NSString*)elecTimeout;

@end
