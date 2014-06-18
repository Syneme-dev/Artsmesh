//
//  AMLocalMesher.h
//  AMMesher
//
//  Created by Wei Wang on 6/16/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMHeartBeatDelegate;

@interface AMLocalMesher : NSObject
@property NSString* server;
@property NSString* serverPort;

-(id)initWithServer:(NSString*)ip
               port:(NSString*)port
        userTimeout:(int)seconds
               ipv6:(BOOL)useIpv6;

-(void)startLocalServer;
-(void)stopLocalServer;

-(void)startLocalClient;
-(void)stopLocalClient;

-(void)changeGroupName:(NSString*)newGroupName;
-(void)goOnline;
-(void)goOffline;


@end
