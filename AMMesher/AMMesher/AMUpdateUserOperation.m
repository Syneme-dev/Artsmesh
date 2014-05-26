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

@implementation AMUpdateUserOperation{
    GCDAsyncUdpSocket* _udpSocket;
    dispatch_queue_t _heartbeatQueue;
    BOOL _shouldRunLoopFinished;
    
}

-(id)initWithServerAddr:(NSString*)addr withPort:(NSString*)port{
    if (self = [super init]) {
        self.serverAddress = addr;
        self.serverPort = port;
        _shouldRunLoopFinished = NO;
    }
    
    return self;
}

-(void)main
{
    _heartbeatQueue = dispatch_queue_create("user_heartbeat_thread_queue", DISPATCH_QUEUE_SERIAL);
    _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:_heartbeatQueue];
    
    NSError *error = nil;
    if (![_udpSocket bindToPort:[self.serverPort intValue] error:&error]){
        
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
    
    //send udp packets
    
    do{
        _shouldRunLoopFinished = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                                          beforeDate:[NSDate distantFuture]];
    }while (_shouldRunLoopFinished != YES);
    
    [_udpSocket close];
    
    //Important: If your app is built with a deployment target of OS X v10.8 and later or iOS v6.0 and later, dispatch queues are typically managed by ARC, so you do not need to retain or release the dispatch queues
    //dispatch_release(_heartbeatQueue);
    
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(MesherOperDidFinished:)
                                                withObject:self waitUntilDone:NO];
    return;
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
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext{
	NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"received string:%@", msg);
    
    _shouldRunLoopFinished = YES;
    self.isSucceeded = YES;
}

@end
