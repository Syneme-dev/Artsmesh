//
//  AMJackClient.h
//  AMAudio
//
//  Created by 王 为 on 8/25/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMJackClient : NSObject

@property BOOL isOpen;

-(BOOL) openJackClient;
-(void) closeJackClient;

-(NSArray*)allChannels;

-(NSArray*)connectionForPort:(NSString*)portName;

-(BOOL)connectSrc:(NSString*)src toDest:(NSString*)dest;
-(BOOL)disconnectChannel:(NSString*)src fromDest:(NSString*) dest;


@end
