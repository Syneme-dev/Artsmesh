//
//  AMHeartBeat.m
//  AMMesher
//
//  Created by lattesir on 5/28/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMHeartBeat.h"
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>

const NSUInteger AMHeartBeatMaxPackageSize = 512;
NSString * const AMHeartBeatErrorDomain = @"AMHeartBeatErrorDomain";

@interface AMHeartBeat ()

- (void)reportError:(int)errorCode;

@end


@implementation AMHeartBeat
{
    int _family;
    NSData *_serverAddress;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"unsupported initializer"
                                 userInfo:nil];
}

- (instancetype)initWithHost:(NSString *)host
                        port:(NSString *)port
                        ipv6:(BOOL)useIpv6
{
    self = [super init];
    if (self) {
        _family = useIpv6 ? PF_INET6 : PF_INET;
        struct addrinfo hints;
        struct addrinfo *ai;
        memset(&hints, 0, sizeof(hints));
        hints.ai_family = _family;
        hints.ai_protocol = IPPROTO_UDP;
        hints.ai_socktype = SOCK_DGRAM;
        if (getaddrinfo([host UTF8String], [port UTF8String], &hints, &ai) < 0) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"getaddrinfo failed"
                                         userInfo:nil];
        }
        _serverAddress = [NSData dataWithBytes:ai->ai_addr
                                        length:ai->ai_addrlen];
        freeaddrinfo(ai);
    }
    return self;
}

- (void)main
{
    NSTimeInterval sleepTime = 0;
    while (!self.isCancelled) {
        if (sleepTime > 0)
            [NSThread sleepForTimeInterval:sleepTime];
        
        if (!self.delegate) {
            sleepTime = self.timeInterval;
            continue;
        }
        
        NSData *data = nil;
        if ([self.delegate respondsToSelector:@selector(heartBeatData)])
            data = [self.delegate heartBeatData];
        if (data == nil || data.length == 0) {
            sleepTime = self.timeInterval;
            continue;
        }
        
        int sockfd = socket(_family, SOCK_DGRAM, IPPROTO_UDP);
        if (sockfd == -1) {
            [self reportError:AMHeartBeatErrorCreateSocketFailed];
            sleepTime = self.timeInterval;
            continue;
        }
        
        NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
        
        struct timeval timeout;
        timeout.tv_sec = self.receiveTimeout;
        timeout.tv_usec = (self.receiveTimeout - timeout.tv_sec) * 1000;
        if (setsockopt(sockfd,SOL_SOCKET,SO_RCVTIMEO,&timeout,
                       sizeof(timeout)) == -1) {
            [self reportError:AMHeartBeatErrorSetSocketTimoutFailed];
            goto cleanup;
        }
        
        ssize_t nbytes = -1;
        nbytes = sendto(sockfd, data.bytes, data.length, 0, _serverAddress.bytes,
                        (socklen_t)_serverAddress.length);
        if (nbytes == -1) {
            [self reportError:AMHeartBeatErrorSendDataFailed];
            goto cleanup;
        }
        if ([self.delegate respondsToSelector:@selector(heartBeat:didSendData:)])
            [self.delegate heartBeat:self didSendData:data];
        data = nil;
        
        char rcvbuf[AMHeartBeatMaxPackageSize];
        socklen_t addrlen = (socklen_t)_serverAddress.length;
        nbytes = recvfrom(sockfd, rcvbuf, sizeof(rcvbuf), 0,
                          (struct sockaddr *)_serverAddress.bytes, &addrlen);
        if (nbytes == -1) {
            int errorCode = (errno == ETIMEDOUT) ?
                AMHeartBeatErrorReceiveTimeout : AMHeartBeatErrorReceiveDataFailed;
            [self reportError:errorCode];
            goto cleanup;
        }
        if ([self.delegate respondsToSelector:@selector(heartBeat:didReceiveData:)])
            [self.delegate heartBeat:self
                         didReceiveData:[NSData dataWithBytes:rcvbuf length:nbytes]];
      
cleanup:
        close(sockfd);
        NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
        sleepTime = self.timeInterval - (now - startTime);
    }
}

- (void)reportError:(int)errorCode
{
    if ([self.delegate respondsToSelector:@selector(heartBeat:didFailWithError:)]) {
        NSError *error = [NSError errorWithDomain:AMHeartBeatErrorDomain
                                             code:errorCode
                                         userInfo:nil];
        [self.delegate heartBeat:self didFailWithError:error];
    }
}

@end