//
//  AMHolePunchingSocket.h
//  AMMesher
//
//  Created by Wei Wang on 5/30/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AM_NAT_ADDR_CHANGED @"AM_NAT_ADDR_CHANGED"

@protocol AMHolePunchingSocketDelegate;

extern NSString * const AMHolePunchingSocketErrorDomain;


enum {
    AMHolePunchingSocketErrorSocketFailed,
    AMHolePunchingSocketErrorSendDataFailed,
    AMHolePunchingSocketErrorReceiveDataFailed,
};


@interface AMHolePunchingPeer : NSObject
@property NSString* peerId;
@property NSString* ip;
@property NSString* port;
@property NSDate* lastHearbeat;
@property BOOL recvTimeout;
-(id)initWithIp:(NSString*)ip port:(NSString*)port peerId:(NSString*)peerId;
@end


@interface AMHolePunchingServer:NSObject
@property NSString* serverIp;
@property NSString* serverPort;
@property NSDate* lastHeartbeat;
@property BOOL recvTimeout;
-(id)initWithIp:(NSString*)ip port:(NSString*)port;
@end



@interface AMHolePunchingSocket : NSObject

@property AMHolePunchingServer* stunServer;
@property NSString* clientPort;
@property NSString* moduleId;
@property NSArray* peers;
@property NSTimeInterval heartbeatInterval;
@property (weak) id<AMHolePunchingSocketDelegate> delegate;

-(id)initWithServer:(NSString*)serverIp
         serverPort:(NSString*)serverPort
         clientPort:(NSString*)clientPort
       timeInterval:(NSTimeInterval)heartbeatInterval
           moduleId:(NSString*)moduleId;

-(void)startHolePunching;
-(void)stopHolePunching;

-(void)broadcastData:(NSData*)data;
-(long)sendDataToPeer:(NSString*) peerId data:(NSData*)data;

-(NSString*)NATMappedPort;
-(NSString*)NATMappedIp;

@end



@protocol AMHolePunchingSocketDelegate <NSObject>

@optional
- (void)holePunchingSocket:(AMHolePunchingSocket *)sock
     didNotSendDataWithTag:(long)tag dueToError:(NSError *)error;

- (void)holePunchingSocket:(AMHolePunchingSocket *)sock didSendDataWithTag:(long)tag;

- (void)holePunchingSocket:(AMHolePunchingSocket *)sock
            didReceiveData:(NSData *)data
               fromPeer:(AMHolePunchingPeer *)peer
         withFilterContext:(id)filterContext;

- (void)socket:(AMHolePunchingSocket *)socket failedWithError:(NSError *)error;

@end

