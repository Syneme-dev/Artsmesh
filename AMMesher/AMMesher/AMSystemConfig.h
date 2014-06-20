//
//  AMSystemConfig.h
//  AMMesher
//
//  Created by Wei Wang on 5/29/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMSystemConfig : NSObject

//Client
@property NSString* globalServerAddr;
@property NSString* globalServerPort;
@property NSString* localServerAddr;
@property NSString* localServertPort;
@property NSString* heartbeatInterval;
@property NSString* heartbeatRecvTimeout;
@property NSString* maxHeartbeatFailure;
@property NSString* chatPort;
@property NSString* stunServerAddr;
@property NSString* stunServerPort;


//Server
@property NSString* myServerUserTimeout;
@property NSString* myServerPort;

//Client And Server
@property BOOL useIpv6;

@end
