//
//  AMUserTTLOperation.h
//  AMMesher
//
//  Created by 王 为 on 3/31/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMMesherOperationProtocol.h"

@interface AMUserTTLOperation : NSOperation

@property id <AMMesherOperationProtocol> delegate;
@property (readonly) BOOL isResultOK;


-(id)initWithParameter:(NSString*)hostAddr
            serverPort:(NSString*)cp
              username:(NSString*)username
             groupname:(NSString*)groupname
               ttltime:(int)ttltime
              delegate:(id<AMMesherOperationProtocol>)delegate;

@end
