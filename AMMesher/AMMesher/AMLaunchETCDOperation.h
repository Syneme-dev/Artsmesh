//
//  AMLaunchETCDOperation.h
//  AMMesher
//
//  Created by Wei Wang on 3/30/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMMesherOperationProtocol.h"

@interface AMLaunchETCDOperation : NSOperation

@property id <AMMesherOperationProtocol> delegate;
@property (readonly) BOOL isResultOK;

-(id)initWithParameter:(NSString*)hostAddr
            serverPort:(NSString*)cp
            clientPort:(NSString*)sp
                 peers:(NSString*)peers
     heartbeatInterval:(NSString*)hbInterval
       electionTimeout:(NSString*)elecTimeout
              delegate:(id<AMMesherOperationProtocol>)delegate;

@end
