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
@property  NSString* action;
@end

@protocol AMUserRequestDelegate <NSObject>
@optional

- (NSString*)httpBaseURL;
- (NSString*)httpMethod:(NSString*)action;
- (NSDictionary*)httpBody:(NSString*)action;
- (void)userRequestDidCancel;
- (void)userrequest:(AMUserRequest *)userrequest didReceiveData:(NSData *)data action:(NSString*) action;
- (void)userrequest:(AMUserRequest *)userrequest didFailWithError:(NSError *)error action:(NSString*) action;

@end
