//
//  AMHolePunchingClient.h
//  AMMesher
//
//  Created by 王 为 on 5/14/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMHolePunchingClient : NSObject

@property NSString* myPublicIp;
@property NSString* myChatPort;
@property NSString* myChatPortMap;

-(id)initWithPort:(NSString*)port server:(NSString*)ip serverPort:(NSString*)port;

-(void)startHolePunching;

-(void)sendPacket:(NSData*)data toHost:(NSString*)ip toPort:(NSString*)toPort;




@end
