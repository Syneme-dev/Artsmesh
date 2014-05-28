//
//  AMMesher.h
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMMesherOperationDelegate;
@class AMUser;

@protocol AMMesherDelegate <NSObject>

-(void)onMesherError:(NSError*)err;

@end

@interface AMMesher: NSObject<AMMesherOperationDelegate>

@property AMUser* mySelf;
@property NSString* localLeaderName;
@property BOOL isLeader;
@property BOOL isOnline;
@property id<AMMesherDelegate> delegate;

+(id)sharedAMMesher;

-(void)startMesher;
-(void)goOnline;
-(void)goOffline;
-(void)stopMesher;

-(void)joinGroup:(NSString*)groupName;
-(void)backToArtsmesh;


@end    


