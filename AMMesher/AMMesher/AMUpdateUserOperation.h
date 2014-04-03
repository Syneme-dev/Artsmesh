//
//  AMUpdateUserOperation.h
//  AMMesher
//
//  Created by Wei Wang on 3/30/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol AMMesherOperationProtocol;

@interface AMUpdateUserOperation : NSOperation

@property id <AMMesherOperationProtocol> delegate;
@property (readonly) BOOL isResultOK;

-(id)initWithParameter:(NSString*)hostAddr
            serverPort:(NSString*)cp
              username:(NSString*)username
             groupname:(NSString*)groupname
     changedProperties:(NSDictionary*)keyvalues
              delegate:(id<AMMesherOperationProtocol>)delegate;

@end
