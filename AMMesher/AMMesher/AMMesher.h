//
//  AMMesher.h
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMUser;
@interface AMMesher: NSObject

@property AMUser* mySelf;
@property NSMutableArray* allUsers;

+(id)sharedAMMesher;
-(void)startLoalMesher;

//@property NSString* leaderName;
//@property int etcdState;    //0 stop, 1 running, 2 error
//
//@property (readonly) NSArray* myGroupUsers;
//@property (readonly) NSArray* allGroupUsers;
//@property BOOL isOnline;
//@property BOOL isLeader;
//

//+(NSOperationQueue*)sharedEtcdOperQueue;
//
//
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


