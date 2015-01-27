//
//  AMHttpAsyncRequest.h
//  AMMesher
//
//  Created by 王 为 on 6/30/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AMHttpAsyncRequestFalied -1
extern NSString * const AMHttpAsyncRequestDomain;

@interface AMHttpAsyncRequest : NSOperation

@property (nonatomic) NSString* baseURL;
@property (nonatomic) NSString* requestPath;
@property (nonatomic) NSDictionary* formData;
@property (nonatomic) NSString* httpMethod;
@property (nonatomic) int httpTimeout;
@property (nonatomic) NSString* username;
@property (nonatomic) NSString* password;
@property (nonatomic) int delay;

@property (nonatomic, strong) void(^requestCallback)(NSData* response, NSError* error, BOOL isCancel);

@end
