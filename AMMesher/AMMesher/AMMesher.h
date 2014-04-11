//
//  AMMesher.h
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMETCDDataDestination;
@protocol AMETCDOperationDelegate;

@interface AMMesher : NSObject<AMETCDOperationDelegate>

@property (atomic) NSMutableArray* userGroups;

@property BOOL isLeader;
@property int groupsState;  //0 local, 1 online, 2 merged
@property int etcdState;    //0 stop, 1 running, 2 error
@property AMETCDDataDestination* usergroupDest;

+(id)sharedAMMesher;
+(NSOperationQueue*)sharedEtcdOperQueue;

-(void)startLoalMesher;
-(void)stopLocalMesher;

-(void)goOnline;

@end    


