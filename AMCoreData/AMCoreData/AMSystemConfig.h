//
//  AMSystemConfig.h
//  AMCoreData
//
//  Created by Wei Wang on 7/17/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMSystemConfig : NSObject

@property NSString* artsmeshAddr;
@property NSString* artsmeshPort;

@property NSHost*   localServerHost;
@property NSString* localServerPort;

@property NSString* remoteHeartbeatInterval;
@property NSString* localHeartbeatInterval;
@property NSString* remoteHeartbeatRecvTimeout;
@property NSString* localHeartbeatRecvTimeout;
@property NSString* serverHeartbeatTimeout;
@property NSString* maxHeartbeatFailureCount;
@property NSString* stunServerAddr;
@property NSString* stunServerPort;
@property NSString* internalChatPort;
@property NSString* useIpv6;

@end
