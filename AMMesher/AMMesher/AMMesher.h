//
//  AMMesher.h
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
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
+(NSOperationQueue*)sharedEtcdOperQueue;

-(void)startLoalMesher;
-(void)stopLocalMesher;


@end

@protocol UserGroupChangeHandler <NSObject>

-(void)handleUserGroupChange:(NSArray*)userGroups;

@end


