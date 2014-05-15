//
//  AMChatHolePunchingClient.h
//  AMMesher
//
//  Created by 王 为 on 5/14/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMChatHolePunchingClientDelegate <NSObject>

-(void)handleIncomingData:(NSData*)data fromAddress:(NSData*)address;

@end

@interface AMChatHolePunchingClient : NSObject

@property id msgDelegate;

-(id)initWithPort:(NSString*)port server:(NSString*)ip serverPort:(NSString*)port;

-(void)startHolePunching;
-(void)stopHolePunching;

-(void)sendPacket:(NSData*)data toHost:(NSString*)ip toPort:(NSString*)toPort;

@end
