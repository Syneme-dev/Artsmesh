//
//  AMMesher.h
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UserGroupChangeHandler;
@protocol AMMesherOperationProtocol;

@interface AMMesher : NSObject<AMMesherOperationProtocol>

@property  (atomic) NSString* myGroupName;
@property  (atomic) NSString* myUserName;
@property  (atomic) NSString* myDomain;
@property  (atomic) NSString* myDescription;
@property  (atomic) NSString* myStatus;
@property  (atomic) NSString* myIp;

@property  (atomic) NSMutableArray* groups;

+(id)sharedAMMesher;

-(void)startLoalMesher;
-(void)stopLocalMesher;

-(void)addUserGroupObserver:(id)observer;
-(void)removeUserGroupObserver:(id<UserGroupChangeHandler>)observer;

@end

@protocol UserGroupChangeHandler <NSObject>

-(void)handleUserGroupChange:(NSArray*)groups;
-(void)handleUserGroupQueryFinished:(NSArray *)groups;

@end
