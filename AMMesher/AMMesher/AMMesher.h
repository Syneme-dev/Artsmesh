//
//  AMMesher.h
//  AMMesher
//
//  Created by Wei Wang on 3/10/14.
//  Copyright (c) 2014 Wei Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MESHER_STATE_ERROR         -1
#define MESHER_STATE_STOP           0
#define MESHER_STATE_PUBLISHING     1
#define MESHER_STATE_PUBLISHED      2
#define MESHER_STATE_JOINING        3
#define MESHER_STATE_JOINED         4

//the state machine is:
// * any state, event stop, to MESHER_STATE_STOP
// * MESHER_STATE_STOP, event start, to MESHER_STATE_PUBLISHING, event publish_ok, to MESHER_STATE_PUBLISHED
// * MESHER_STATE_STOP, event start, to MESHER_STATE_PUBLISHING, event publish_error, to MESHER_STATE_JOINING, event join_ok, to MESHER_STATE_JOINED
// * MESHER_STATE_STOP, event start, to MESHER_STATE_PUBLISHING, event publish_error, to MESHER_STATE_JOINING, event join_error, to MESHER_STATE_ERROR
// * MESHER_STATE_JOINING, event host quit, to MESHER_STATE_PUBLISHING, event publish_ok, to MESHER_STATE_PUBLISHED
// * MESHER_STATE_JOINING, event host quit, to MESHER_STATE_PUBLISHING, event publish_error, to MESHER_STATE_JOINING, event join_ok, to MESHER_STATE_JOINED
// * MESHER_STATE_JOINING, event host quit, to MESHER_STATE_PUBLISHING, event publish_error, to MESHER_STATE_JOINING, event join_error, to MESHER_STATE_ERROR


@class AMMesher;

@protocol MesherDelegate
- (void) mesherFailed:(AMMesher *)mesher reason:(NSString *)reason;
@end


@interface AMMesher : NSObject<NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@property int state; // 0 stop, 1 started, 2 joined, 3 hosting, 4 electing, -1 error

//LAN
-(BOOL)start;
-(void)stop;

//TODO
//communicate with WLAN mesher

@end
