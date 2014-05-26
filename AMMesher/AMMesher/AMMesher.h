//
//  AMMesher.h
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "AMETCDOperationDelegate.h"
//@protocol AMETCDOperationDelegate;


//@class AMETCDDataDestination;
//@interface AMMesher : NSObject<AMETCDOperationDelegate>
@class AMUser;
@interface AMMesher: NSObject

@property AMUser* mySelf;
//@property NSString* leaderName;
//@property int etcdState;    //0 stop, 1 running, 2 error
//
//@property (readonly) NSArray* myGroupUsers;
//@property (readonly) NSArray* allGroupUsers;
//@property BOOL isOnline;
//@property BOOL isLeader;
//
//+(id)sharedAMMesher;
//+(NSOperationQueue*)sharedEtcdOperQueue;
//
//-(void)startLoalMesher;
//-(void)stopLocalMesher;
//
//-(void)joinGroup:(NSString*)groupName;
//-(void)everyoneJoinGroup:(NSString*)groupName;
//-(void)backToArtsmesh;
//
//-(void)everyoneGoOnline;
//-(void)goOnline;
//-(void)goOffline;
//
//-(void)updateMySelfProperties:(NSDictionary*) properties;

@end    


