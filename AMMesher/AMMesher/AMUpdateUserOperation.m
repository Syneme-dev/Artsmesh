//
//  AMUpdateUserOperation.m
//  AMMesher
//
//  Created by Wei Wang on 5/26/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMUpdateUserOperation.h"
#import "AMMesherOperationDelegate.h"
#import "AMNetworkUtils/GCDAsyncUdpSocket.h"
#import "AMMesher.h"
#import "AMUser.h"

@implementation AMUpdateUserOperation{
    
    GCDAsyncUdpSocket* _udpSocket;
    dispatch_queue_t _heartbeatQueue;
    BOOL _shouldRunLoopFinished;
    NSTimer* _sendTimer;
    int _sendPeroid;
    int _retryTimes;
    int _maxRetryTimes;
    
}

-(id)initWithServerAddr:(NSString*)addr withPort:(NSString*)port{
    if (self = [super init]) {
        self.serverAddress = addr;
        self.serverPort = port;
        _shouldRunLoopFinished = NO;
        _sendPeroid = 6;
        _retryTimes = 0;
        _maxRetryTimes = 3;
    }
    
    return self;
}

-(void)main
{
    if (self.isCancelled) {
        self.isSucceeded = YES;
        self.errorDescription = @"task is canceled!";
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(MesherOperDidFinished:)
                                                    withObject:self waitUntilDone:NO];
        return;
    }
    
    _heartbeatQueue = dispatch_queue_create("user_heartbeat_thread_queue", DISPATCH_QUEUE_SERIAL);
    _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:_heartbeatQueue];
    
    NSError *error = nil;
    if (![_udpSocket bindToPort:0 error:&error]){
        
        self.isSucceeded = NO;
        self.errorDescription = [NSString stringWithFormat:@"init udp socket error: %@",
                                 error.description];
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(MesherOperDidFinished:)
                                                    withObject:self waitUntilDone:NO];
        return;
    }
    if (![_udpSocket beginReceiving:&error]){
        
        self.isSucceeded = NO;
        self.errorDescription = [NSString stringWithFormat:@"init udp socket error: %@",
                                 error.description];
        [_udpSocket close];
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(MesherOperDidFinished:)
                                                    withObject:self waitUntilDone:NO];
        return;
    }
    
    [self sendUdpPacket];
    
    //dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    do{
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    }while (!_shouldRunLoopFinished);
    
    [_udpSocket close];
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(MesherOperDidFinished:)
                                                withObject:self waitUntilDone:NO];
    return;
}

-(void)sendUdpPacket{
    
    if (_retryTimes >= _maxRetryTimes || self.isCancelled) {
        _shouldRunLoopFinished  = YES;
        self.isSucceeded = NO;
        self.errorDescription = @"send udp packets to server failed after 5 times retry!";
        return;
    }
    
    //make sure the action type is the same
    self.udpRequest.action = self.action;
    NSData* jsonData = [self.udpRequest jsonData];
    [_udpSocket sendData:jsonData toHost:self.serverAddress
                    port:[self.serverPort intValue] withTimeout:-1 tag:0];
    _sendTimer = [NSTimer scheduledTimerWithTimeInterval:_sendPeroid target:self selector:@selector(sendUdpPacket) userInfo:nil repeats:NO];
    
    _retryTimes++;
}

#pragma mark -
#pragma mark GCDAsyncUdpSocket Delegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
	// You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    self.isSucceeded = NO;
    self.errorDescription = [NSString stringWithFormat:@"send heartbeat packets failed: %@",
                             error.description];
    _shouldRunLoopFinished = YES;
   // dispatch_semaphore_signal(_semaphore);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext{
    
	NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"received json string:%@", jsonStr);

    self.udpResponse = [AMUserUDPResponse responseFromJsonData:data];
    if (self.udpResponse != nil &&
        [self.udpResponse.action isEqualToString:self.udpRequest.action] &&
        [self.udpResponse.contentMd5 isEqualToString:self.udpRequest.contentMd5] ) {
        
        [_sendTimer invalidate ];
        self.isSucceeded = YES;
        _shouldRunLoopFinished  = YES;
       // dispatch_semaphore_signal(_semaphore);
     
    }
}

@end
