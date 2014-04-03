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
@class AMUserGroupNode;

@interface AMMesher : NSObject<AMMesherOperationProtocol>

@property  (atomic) NSString* myGroupName;
@property  (atomic) NSString* myUserName;
@property  (atomic) NSString* myDomain;
@property  (atomic) NSString* myDescription;
@property  (atomic) NSString* myStatus;
@property  (atomic) NSString* myIp;

@property (atomic) NSMutableArray* userGroups;

+(id)sharedAMMesher;

-(void)startLoalMesher;
-(void)stopLocalMesher;

//-(void)addUserGroupObserver:(id<UserGroupChangeHandler>)handler;
//-(void)removeUserGroupObserver:(id<UserGroupChangeHandler>)handler;

////KVO things
//-(NSUInteger)countOfGroups;
//-(AMUserGroupNode*)objectInGroupsAtIndex:(NSUInteger)index;
//-(void)addGroupsObject:(AMUserGroupNode *)object;
//-(void)insertObject:(AMUserGroupNode *)object inGroupsAtIndex:(NSUInteger)index;
//-(void)replaceObjectInGroupsAtIndex:(NSUInteger)index withObject:(id)object;
//-(void)removeObjectFromGroupsAtIndex:(NSUInteger)index;
//-(void)removeGroupsObject:(AMUserGroupNode *)object;

@end

@protocol UserGroupChangeHandler <NSObject>

-(void)handleUserGroupChange:(NSArray*)userGroups;

@end


