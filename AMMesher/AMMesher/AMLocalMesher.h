//
//  AMLocalMesher.h
//  AMMesher
//
//  Created by Wei Wang on 6/16/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMLocalMesher : NSObject

-(id)initWithServer:(NSString*)ip
               port:(NSString*)port
        userTimeout:(int)seconds
               ipv6:(BOOL)useIpv6;

-(void)startLocalServer;
-(void)stopLocalServer;

-(void)startLocalClient;
-(void)stopLocalClient;

-(BOOL)changeGroupName;
-(void)goOnline;
-(void)goOffline;


@end
