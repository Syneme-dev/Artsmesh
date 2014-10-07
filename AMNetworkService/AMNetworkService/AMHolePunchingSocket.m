//
//  AMHolePunchingSocket.m
//  AMMesher
//
//  Created by Wei Wang on 5/30/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMHolePunchingSocket.h"
#import "AMNetworkUtils/GCDAsyncUdpSocket.h"

#define AMholePunchingPeerPacket    @"HB"
#define AMHeartbeatPacketTag        0
#define AMBroadcastPacketTag        1
#define AMPacketTagStartIndex       2

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
        self.stunServer = [[AMHolePunchingServer alloc] initWithIp:serverIp port:serverPort];
        self.clientPort = clientPort;
        self.heartbeatInterval = heartbeatInterval;
        self.moduleId = moduleId;
        self.peers = [[NSMutableArray alloc] init];
        _tag = AMPacketTagStartIndex;
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
        
        if ([self.delegate respondsToSelector:@selector(socket:failedWithError:)]) {
            
            NSError* err = [NSError errorWithDomain:AMHolePunchingSocketErrorDomain
                                               code:AMHolePunchingSocketErrorSocketFailed
                                           userInfo:nil];
            [self.delegate socket:self failedWithError:err];
        }
        
        return NO ;
    }
    
    if (![_socket beginReceiving:&error]){
        [_socket close];
        
        if ([self.delegate respondsToSelector:@selector(socket:failedWithError:)]) {
            
            NSError* err = [NSError errorWithDomain:AMHolePunchingSocketErrorDomain
                                               code:AMHolePunchingSocketErrorSocketFailed
                                           userInfo:nil];
            [self.delegate socket:self failedWithError:err];
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
               toHost:self.stunServer.serverIp
                 port: [self.stunServer.serverPort intValue]
          withTimeout:-1
                  tag:AMHeartbeatPacketTag];
    
    for (AMHolePunchingPeer* peer in self.peers) {
        [_socket sendData:data
                   toHost:peer.ip
                     port: [peer.port intValue]
              withTimeout:-1
                      tag:AMHeartbeatPacketTag];
    }
}


-(void)checkTimeout
{
    //Check peers
    for (AMHolePunchingPeer* peer in self.peers) {
        
        if (peer.lastHearbeat == nil) {
            continue;
        }
        
        NSTimeInterval interval = [NSDate timeIntervalSinceReferenceDate] - [peer.lastHearbeat timeIntervalSinceReferenceDate];
        if (interval > self.heartbeatInterval*3) {
            peer.recvTimeout = YES;
        }else{
            peer.recvTimeout = NO;
        }
    }
    
    //Check Server
    if (self.stunServer.lastHeartbeat != nil) {
        NSTimeInterval interval = [NSDate timeIntervalSinceReferenceDate] - [self.stunServer.lastHeartbeat timeIntervalSinceReferenceDate];
        if (interval > self.heartbeatInterval*3) {
            self.stunServer.recvTimeout = YES;
        }else{
            self.stunServer.recvTimeout = NO;
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
                      tag:AMBroadcastPacketTag];
    }
}


-(long)sendDataToPeer:(NSString*) peerId data:(NSData*)data
{
    for (AMHolePunchingPeer* peer in self.peers) {
        
        if ([peer.peerId isEqualToString: peerId]) {
            [_socket sendData:data
                       toHost:peer.ip
                         port: [peer.port intValue]
                  withTimeout:-1
                          tag:_tag++];
            return _tag;
        }
    }
    
    return -1;
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    if([self.delegate respondsToSelector:@selector(holePunchingSocket:didSendDataWithTag:)]){
        [self.delegate holePunchingSocket:self didSendDataWithTag:tag];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(holePunchingSocket:didNotSendDataWithTag:dueToError:)]) {
        [self.delegate holePunchingSocket:self didNotSendDataWithTag:tag dueToError:error];
    }
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    //NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString* fromHost = [GCDAsyncUdpSocket hostFromAddress:address];
    
    if ([fromHost isEqualToString:self.stunServer.serverIp]) {
        self.stunServer.lastHeartbeat = [NSDate date];
        [self parsePublicAddr:data];
        
        return;
    }
    
    for (AMHolePunchingPeer* peer in self.peers) {
        if ([peer.ip isEqualToString:fromHost]) {
             NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ([msg isEqualToString:AMholePunchingPeerPacket]) {
                peer.lastHearbeat = [NSDate date];
                
                return;
            }else if([self.delegate respondsToSelector:@selector(holePunchingSocket:didReceiveData:fromPeer:withFilterContext:)]){
                //forward data to delegate
                [self.delegate holePunchingSocket:self didReceiveData:data fromPeer:peer withFilterContext:nil];
                
                return;
            }
        }
    }
}

-(void)parsePublicAddr:(NSData*)data
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray* ipAndPort = [msg componentsSeparatedByString:@":"];
    if ([ipAndPort count] < 2){
        return;
    }
    
    BOOL natAddrChanged = NO;
    if(![_mappedIp isEqualToString:[ipAndPort objectAtIndex:0]]){
        _mappedIp = [ipAndPort objectAtIndex:0];
        natAddrChanged = YES;
    }
    
    if(![_mappedPort isEqualToString:[ipAndPort objectAtIndex:1]]){
        _mappedPort = [ipAndPort objectAtIndex:1];
        natAddrChanged = YES;
    }
    
    if (natAddrChanged) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:AM_NAT_ADDR_CHANGED
         object:nil
         userInfo:@{@"natip" : _mappedIp,
                    @"natport":_mappedPort}];
    }
}



@end


@implementation AMHolePunchingPeer

-(id)initWithIp:(NSString*)ip port:(NSString*)port peerId:(NSString*)peerId
{
    if (self = [super init]) {
        self.ip = ip;
        self.port = port;
        self.peerId = peerId;
        self.lastHearbeat = nil;
        self.recvTimeout = NO;
    }
    
    return self;
}

@end

@implementation AMHolePunchingServer

-(id)initWithIp:(NSString*)ip port:(NSString*)port
{
    if (self = [super init]) {
        self.serverIp = ip;
        self.serverPort = port;
        self.lastHeartbeat = nil;
        self.recvTimeout = NO;
    }
    
    return self;
}

@end
