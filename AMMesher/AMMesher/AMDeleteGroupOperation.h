//
//  AMDeleteGroupOperation.h
//  AMMesher
//
//  Created by 王 为 on 4/3/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol AMMesherOperationProtocol;

@interface AMDeleteGroupOperation : NSOperation

@property id <AMMesherOperationProtocol> delegate;
@property (readonly) BOOL isResultOK;

-(id)initWithParameter:(NSString*)hostAddr
            serverPort:(NSString*)cp
             groupname:(NSString*)groupname
              delegate:(id<AMMesherOperationProtocol>)delegate;

@end
