//
//  AMMesher.h
//  AMMesher
//
//  Created by Wei Wang on 3/10/14.
//  Copyright (c) 2014 Wei Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MESHER_STATE_STOP       0
#define MESHER_STATE_START      1
#define MESHER_STATE_JOINED     2
#define MESHER_STATE_HOSTING    3

@class AMMesher;

@protocol MesherBrowserDelegate
- (void)updateServerList;
@end

@protocol MesherDelegate
// Mesher has been terminated because of an error
- (void) startMesherFailed:(AMMesher *)mesher reason:(NSString *)reason;
@end


@interface AMMesher : NSObject<NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@property NSMutableArray* meshers;
@property id<MesherBrowserDelegate>  delegate;
@property int mesherState; // 0 stop, 1 started, 2 joined, 3 hosting

//LAN
-(BOOL)start;
-(void)stop;

-(BOOL)joinLocalMesher:(int) index;
-(BOOL)publishLocalMesher;

//TODO
//communicate with WLAN mesher

@end
