//
//  AMHttpSyncRequest.h
//  AMMesher
//
//  Created by 王 为 on 6/30/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMHttpSyncRequest : NSObject

@property NSString* baseURL;
@property NSString* requestPath;
@property NSString* httpMethod;
@property NSDictionary* formData;
@property int httpTimeout;
@property NSString* username;
@property NSString* password;

-(NSData*)sendRequest;

@end
