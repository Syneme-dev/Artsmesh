//
//  AMUserRequest.h
//  AMMesher
//
//  Created by Wei Wang on 5/29/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol AMUserRequestDelegate;

extern NSString * const AMUserRequestDomain;
#define AMUserRequestFalied -1

@interface AMUserRequest : NSOperation
@property(nonatomic, weak) id<AMUserRequestDelegate> delegate;
@property  NSString* requestPath;
@property NSDictionary* formData;
@end

@protocol AMUserRequestDelegate <NSObject>
@optional

- (NSString*)httpBaseURL;
- (NSString*)httpMethod:(NSString*)action;
- (NSDictionary*)httpBodyForm:(NSString*)action;
- (void)userRequestDidCancel;
- (void)userrequest:(AMUserRequest *)userrequest didReceiveData:(NSData *)data;
- (void)userrequest:(AMUserRequest *)userrequest didFailWithError:(NSError *)error;

@end
