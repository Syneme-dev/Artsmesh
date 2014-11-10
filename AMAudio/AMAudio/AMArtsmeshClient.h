//
//  AMArtsmeshClient.h
//  AMAudio
//
//  Created by 王为 on 10/11/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMJackPort.h"
@protocol AMJackClientDelegate;

@interface AMArtsmeshClient : NSObject

@property id<AMJackClientDelegate> delegate;
@property (readonly) NSMutableArray* portPairs;

-(id)initWithChannelCounts:(int)nCounts;
-(BOOL)registerClient;
-(void)unregisterClient;
-(NSArray*)allPorts;

@end


@protocol AMJackClientDelegate <NSObject>

@optional

-(void)jackShutDownClient:(AMArtsmeshClient*)client;
-(void)clientRegistered:(NSString*)clientName;
-(void)clientUnregistered:(NSString*)clientName;
-(void)portRegistered:(unsigned int)portId;
-(void)portUnregistered:(unsigned int)portId;

@end


@interface PortPair : NSObject

@property AMJackPort* inputPort;
@property AMJackPort* outputPort;

@end
