//
//  AMMesherOperation.h
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMMesherOperationDelegate;

@interface AMMesherOperation : NSOperation

@property NSString* action;
@property  BOOL isSucceeded;
@property  NSString* errorDescription;
@property  id<AMMesherOperationDelegate> delegate;

@end



