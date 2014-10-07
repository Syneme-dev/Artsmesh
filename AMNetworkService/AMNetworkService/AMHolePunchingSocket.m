//
//  AMHolePunchingSocket.m
//  AMMesher
//
//  Created by Wei Wang on 5/30/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMHolePunchingSocket.h"
#import "AMNetworkUtils/GCDAsyncUdpSocket.h"

#define AMHolePunchingHeartBeatTag  0
#define AMHolePunchingDataTag       1
#define AMholePunchingPeerPacket    @"HB"

NSString * const AMHolePunchingSocketErrorDomain = @"AMHolePunchingSocketErrorDomain";

@implementation AMHolePunchingSocket
{
    GCDAsyncUdpSocket* _socket;
    NSTimer*  _punchingTimer;
    NSTimer*  _checkingTimer;
    NSString* _mappedPort;
    NSString* _mappedIp;
    long _tag;
}

-(id)initWithServer:(NSString*)serverIp
         serverPort:(NSString*)serverPort
         clientPort:(NSString*)clientPort
       timeInterval:(NSTimeInterval)heartbeatInterval
           moduleId:(NSString*)moduleId
{
    if (self = [super init]) {
        self.serverIp = serverIp;
        self.serverPort = serverPort;
        self.clientPort = clientPort;
        self.heartbeatInterval = heartbeatInterval;
        self.moduleId = moduleId;
        self.peers = [[NSMutableArray alloc] init];
        _tag = 0;
    }
    
    return self;
}


-(void)startHolePunching
{
    BOOL ret = [self initSocket];
    if (!ret) {
        return;
    }
    
    _punchingTimer = [NSTimer scheduledTimerWithTimeInterval:self.heartbeatInterval
                                                      target:self
                                                    selector:@selector(sendHeartbeat)
                                                    userInfo:nil
                                                     repeats:YES];
    
    _checkingTimer = [NSTimer scheduledTimerWithTimeInterval:self.heartbeatInterval * 3
                                                      target:self
                                                    selector:@selector(checkTimeout)
                                                    userInfo:nil
                                                     repeats:YES];
}


-(void)stopHolePunching{
    [self closeSocket];
    [_punchingTimer invalidate];
    _punchingTimer = nil;
}


-(BOOL)initSocket
{
    _socket = [[GCDAsyncUdpSocket alloc]
               initWithDelegate:self
               delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    if (![_socket bindToPort:[self.clientPort intValue] error:&error]){
        
        if ([self.delegate respondsToSelector:@selector(socket:didFailWithError:toPeer:)]) {
            
            NSError* err = [NSError errorWithDomain:AMHolePunchingSocketErrorDomain
                                               code:AMHolePunchingSocketErrorSocketFailed
                                           userInfo:nil];
            [self.delegate socket:self didFailWithError:err toPeer:nil];
        }
        
        return NO ;
    }
    
    if (![_socket beginReceiving:&error]){
        [_socket close];
        
        if ([self.delegate respondsToSelector:@selector(socket:didFailWithError:toPeer:)]) {
            
            NSError* err = [NSError errorWithDomain:AMHolePunchingSocketErrorDomain
                                               code:AMHolePunchingSocketErrorSocketFailed
                                           userInfo:nil];
            [self.delegate socket:self didFailWithError:err toPeer:nil];
        }
        
        return NO;
    }
    
    return YES;
}


-(void)closeSocket
{
    [_socket close];
    _socket = nil;
}


-(NSString*)NATMappedPort
{
    return _mappedPort;
}


-(NSString*)NATMappedIp
{
    return _mappedIp;
}


-(void)sendHeartbeat{
    NSData *data = [AMholePunchingPeerPacket dataUsingEncoding:NSUTF8StringEncoding];
    
    [_socket sendData:data
               toHost:self.serverIp
                 port: [self.serverPort intValue]
          withTimeout:-1
                  tag:AMHolePunchingDataTag];
    
    for (AMHolePunchingPeer* peer in self.peers) {
        [_socket sendData:data
                   toHost:peer.ip
                     port: [peer.port intValue]
              withTimeout:-1
                      tag:AMHolePunchingDataTag];
    }
}


-(void)checkTimeout
{
    for (AMHolePunchingPeer* peer in self.peers) {
        
        NSTimeInterval interval = [NSDate timeIntervalSinceReferenceDate] - [peer.lastHeartBeatTime timeIntervalSinceReferenceDate];
        if (interval > self.heartbeatInterval*3) {
            peer.timeout = YES;
        }else{
            peer.timeout = NO;
        }
    }
}


-(void)broadcastData:(NSData*)data
{
    for (AMHolePunchingPeer* peer in self.peers) {
        [_socket sendData:data
                   toHost:peer.ip
                     port: [peer.port intValue]
              withTimeout:-1
                      tag:0];
    }
}


-(void)sendDataToPeer:(NSString*) peerId data:(NSData*)data dataTag:(long)tag
{
    for (AMHolePunchingPeer* peer in self.peers) {
        
        if ([peer.peerId isEqualToString: peerId]) {
            
            @synchronized(self)
            {
                [_socket sendData:data
                           toHost:peer.ip
                             port: [peer.port intValue]
                      withTimeout:-1
                              tag:_tag++];
                
            }
        }
    }
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    if([self.delegate respondsToSelector:@selector(socket:didSendData:toPeer:)]){
        self
    }
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(socket:didNotSendData:)]) {
        [self.delegate socket:self didNotSendData:error];
    }
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString* fromHost = [GCDAsyncUdpSocket hostFromAddress:address];
    
    if([_hostIps containsObject:fromHost]){
        if ([self.delegate respondsToSelector:@selector(socket:didReceiveDataFromServer:)]) {
            [self.delegate socket:self didReceiveDataFromServer:data];
        }
        return;
    }

    if ([msg isEqualToString:AMholePunchingPeerPacket]) {
        //peer packet
        NSLog(@"heartbeat from %@", fromHost);
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(socket:didReceiveData:)]) {
        [self.delegate socket:self didReceiveData:data];
    }
}

@end


@implementation AMHolePunchingPeer

@end
