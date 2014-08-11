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
    NSString* _serverIp;
    NSString* _serverPort;
    NSString* _internalPort;
    NSString* _mappedPort;
    NSString* _mappedIp;
    
    NSTimer*  _punchingTimer;
    GCDAsyncUdpSocket* _socket;
    NSArray* _hostIps;
}

- (instancetype)initWithServer:(NSString*)serverIp
                    serverPort:(NSString*)serverPort
                    clientPort:(NSString*)clientPort
{
    if (self = [super init]) {
        _serverIp = serverIp;
        _serverPort = serverPort;
        _internalPort = clientPort;
        self.timeInterval = 5;
        self.localPeers = [[NSMutableArray alloc] init];
        self.remotePeers = [[NSMutableArray alloc] init];
        
        NSHost* serverHost = [NSHost hostWithName:serverIp];
        _hostIps = [serverHost addresses];
    }
    
    return self;
}

-(void)initSocket
{
    _socket = [[GCDAsyncUdpSocket alloc]
               initWithDelegate:self
               delegateQueue:dispatch_get_main_queue()];
    
    if (self.useIpv6) {
        [_socket setPreferIPv6];
    }
    
    NSError *error = nil;
    if (![_socket bindToPort:[_internalPort intValue] error:&error]){
        
        if ([self.delegate respondsToSelector:@selector(socket:didFailWithError:)]) {
            
            NSError* err = [NSError errorWithDomain:AMHolePunchingSocketErrorDomain
                                               code:AMHolePunchingSocketErrorSocketFailed
                                           userInfo:nil];
            [self.delegate socket:self didFailWithError:err];
        }
        
        return ;
    }
    if (![_socket beginReceiving:&error]){
        [_socket close];
        
        if ([self.delegate respondsToSelector:@selector(socket:didFailWithError:)]) {
            
            NSError* err = [NSError errorWithDomain:AMHolePunchingSocketErrorDomain
                                               code:AMHolePunchingSocketErrorSocketFailed
                                           userInfo:nil];
            [self.delegate socket:self didFailWithError:err];
        }
        
        return;
    }

}

-(void)startHolePunching
{
    if (self.useIpv6) {
        return;
    }
   
    _punchingTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(sendHeartbeat) userInfo:nil repeats:YES];
}

-(void)dealloc
{
    [self closeSocket];
}

-(void)closeSocket
{
    [_socket close];
    _socket = nil;
}


-(void)stopHolePunching{
    [_punchingTimer invalidate];
    _punchingTimer = nil;
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
    
    [_socket sendData:data toHost:_serverIp port: [_serverPort intValue] withTimeout:-1 tag:AMHolePunchingDataTag];
    
    for (AMHolePunchingPeer* peer in self.remotePeers) {
        [_socket sendData:data toHost:peer.ip  port: [peer.port intValue] withTimeout:-1 tag:AMHolePunchingDataTag];
    }
}


-(void)sendPacketToPeers:(NSData*)data
{
    for (AMHolePunchingPeer* peer in self.remotePeers) {
        [_socket sendData:data toHost:peer.ip  port: [peer.port intValue] withTimeout:-1 tag:AMHolePunchingHeartBeatTag];
    }
    
    for (AMHolePunchingPeer* peer in self.localPeers) {
        [_socket sendData:data toHost:peer.ip  port: [peer.port intValue] withTimeout:-1 tag:AMHolePunchingHeartBeatTag];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
	// You could add checks here
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
