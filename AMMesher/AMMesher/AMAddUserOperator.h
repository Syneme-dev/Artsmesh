//
//  AMAddUserOperator.h
//  AMMesher
//
//  Created by Wei Wang on 3/30/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMMesherOperationProtocol.h"

@interface AMAddUserOperator : NSOperation

@property id <AMMesherOperationProtocol> delegate;
@property (readonly) BOOL isResultOK;

-(id)initWithParameter:(NSString*)hostAddr
            serverPort:(NSString*)cp
              username:(NSString*)username
             groupname:(NSString*)groupname
            userdomain:(NSString*)userdomain
                userip:(NSString*)userip
            userStatus:(NSString*)userStatus
       userDiscription:(NSString*)userDiscription
              delegate:(id<AMMesherOperationProtocol>)delegate;

@end

