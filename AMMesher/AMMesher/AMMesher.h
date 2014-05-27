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
@property NSMutableArray* allUsers;
@property NSString* uselistVersion;
@property NSString* localLeaderName;
@property BOOL isLeader;
@property BOOL isOnline;
@property id<AMMesherDelegate> delegate;

+(id)sharedAMMesher;

-(void)startLoalMesher;
-(void)stopLocalMesher;
-(void)joinGroup:(NSString*)groupName;
-(void)backToArtsmesh;
-(void)goOnline;

@end    


