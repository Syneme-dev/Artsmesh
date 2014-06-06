//
//  AMHolePunchingSocket.h
//  AMMesher
//
//  Created by Wei Wang on 5/30/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol AMHolePunchingSocketDelegate;

extern NSString * const AMHolePunchingSocketErrorDomain;

enum {
    AMHolePunchingSocketErrorSocketFailed,
    AMHolePunchingSocketErrorSendDataFailed,
    AMHolePunchingSocketErrorReceiveDataFailed,
};

@interface AMHolePunchingSocket : NSObject

@property NSTimeInterval timeInterval;
@property NSMutableArray* localPeers;
@property NSMutableArray* remotePeers;
@property BOOL useIpv6;
@property id<AMHolePunchingSocketDelegate> delegate;

- (instancetype)initWithServer:(NSString*)serverIp
                    serverPort:(NSString*)serverPort
                    clientPort:(NSString*)clientPort;
-(void)initSocket;
-(void)startHolePunching;
-(void)stopHolePunching;
-(void)sendPacketToPeers:(NSData*)data;
-(NSString*)NATMappedPort;
-(NSString*)NATMappedIp;

@end


@interface AMHolePunchingPeer : NSObject

@property NSString* ip;
@property NSString* port;

@end

@protocol AMHolePunchingSocketDelegate <NSObject>

@optional
- (void)socket:(AMHolePunchingSocket*) socket didReceiveData:(NSData *)data;
- (void)socket:(AMHolePunchingSocket*) socket didReceiveDataFromServer:(NSData *)data;
- (void)socket:(AMHolePunchingSocket*) socket didNotSendData:(NSError*)err;
- (void)socket:(AMHolePunchingSocket *)socket didFailWithError:(NSError *)error;
@end
