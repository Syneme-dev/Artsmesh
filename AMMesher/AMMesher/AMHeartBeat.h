//
//  AMHeartBeat.h
//  AMMesher
//
//  Created by lattesir on 5/28/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol AMHeartBeatDelegate;

extern const NSUInteger AMHeartBeatMaxPackageSize;
extern NSString * const AMHeartBeatErrorDomain;

enum {
    AMHeartBeatErrorCreateSocketFailed,
    AMHeartBeatErrorSetSocketTimoutFailed,
    AMHeartBeatErrorSendDataFailed,
    AMHeartBeatErrorReceiveDataFailed,
    AMHeartBeatErrorReceiveTimeout
};

@interface AMHeartBeat : NSThread

@property(nonatomic) NSTimeInterval initialDelay;
@property(nonatomic) NSTimeInterval timeInterval;
@property(nonatomic) NSTimeInterval receiveTimeout;
@property(nonatomic, weak) id<AMHeartBeatDelegate> delegate;

// designated initializer
- (instancetype)initWithHost:(NSString *)host
                        port:(NSString *)port
                        ipv6:(BOOL)useIpv6;
- (void)cancelWithData:(NSData *)data;

@end


@protocol AMHeartBeatDelegate<NSObject>
@optional

- (NSData *)heartBeatData;
- (void)heartBeat:(AMHeartBeat *)heartBeat didReceiveData:(NSData *)data;
- (void)heartBeat:(AMHeartBeat *)heartBeat didSendData:(NSData *)data;
- (void)heartBeat:(AMHeartBeat *)heartBeat didFailWithError:(NSError *)error;

@end

