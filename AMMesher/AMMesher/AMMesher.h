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

@interface AMMesher: NSObject

@property AMUser* mySelf;
@property NSMutableArray* allUsers;
@property NSString* localLeaderName;
@property BOOL isLeader;
@property BOOL isOnline;

+(id)sharedAMMesher;

-(void)startLoalMesher;
-(void)stopLocalMesher;
-(void)joinGroup:(NSString*)groupName;
-(void)backToArtsmesh;
-(void)goOnline;

@end    


