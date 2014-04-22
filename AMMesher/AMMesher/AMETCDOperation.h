//
//  AMETCDOperation.h
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMETCDOperationDelegate.h"

@protocol AMETCDOperationDelegate;
@class AMETCDResult;
@class AMETCD;

@interface AMETCDOperation : NSOperation

@property NSString* etdcIp;
@property NSString* etcdPort;
@property id<AMETCDOperationDelegate> delegate;

//should readonly
@property  NSString* operationType; //system, query, update, create, delete
@property  BOOL isResultOK;
@property  NSString* errorDescription;
@property  AMETCDResult* operationResult;
@property  AMETCD* etcdApi;


-(id)init:(NSString*)ip
     port:(NSString*)port;


@end



