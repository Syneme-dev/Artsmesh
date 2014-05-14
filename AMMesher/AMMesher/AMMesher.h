//
//  AMMesher.h
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMETCDOperationDelegate.h"



@protocol AMETCDOperationDelegate;
@class AMETCDDataDestination;
@class AMHolePunchingClient;

@interface AMMesher : NSObject<AMETCDOperationDelegate>

@property AMETCDDataDestination* usergroupDest;
@property NSString* myGroupName;
@property BOOL isLeader;
@property int etcdState;    //0 stop, 1 running, 2 error
@property BOOL isOnline;

@property (readonly) NSString* myUniqueName;
@property (readonly) NSArray* myGroupUsers;
@property (readonly) AMHolePunchingClient* holePunchingClient;

+(id)sharedAMMesher;
+(NSOperationQueue*)sharedEtcdOperQueue;

-(void)startLoalMesher;
-(void)stopLocalMesher;

-(void)joinGroup:(NSString*)groupName;
-(void)everyoneJoinGroup:(NSString*)groupName;
-(void)backToArtsmesh;

-(void)everyoneGoOnline;
-(void)goOnline;
-(void)goOffline;

@end    


