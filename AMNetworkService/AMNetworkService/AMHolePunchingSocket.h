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


@interface AMHolePunchingPeer : NSObject
@property NSString* peerId;
@property NSString* ip;
@property NSString* port;
@property NSDate* lastHeartBeatTime;
@property BOOL timeout;
@property BOOL sendFailed;
@end



@interface AMHolePunchingSocket : NSObject

@property NSString* serverIp;
@property NSString* serverPort;
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

- (void)socket:(AMHolePunchingSocket*) socket
   didSendData:(NSError*)err
        withTag:(long)tag;

- (void)socket:(AMHolePunchingSocket*) socket
didReceiveData:(NSData *)data
      fromPeer:(AMHolePunchingPeer*)peer;

- (void)socket:(AMHolePunchingSocket*) socket
didNotSendData:(NSError*)err
        toPeer:(AMHolePunchingPeer*)peer;



- (void)socket:(AMHolePunchingSocket *)socket
didFailWithError:(NSError *)error
        toPeer:(AMHolePunchingPeer*)peer;

@end

