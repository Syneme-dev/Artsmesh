//
//  AMMesher.h
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol AMMesherOperationProtocol;
@interface AMMesher : NSObject<AMMesherOperationProtocol>

@property  (atomic) NSString* myGroupName;
@property  (atomic) NSString* myUserName;
@property  (atomic) NSString* myDomain;
@property  (atomic) NSString* myDescription;
@property  (atomic) NSString* myStatus;
@property  (atomic) NSString* myIp;

@property  (atomic) NSMutableArray* groups;

+(NSOperationQueue*)sharedEtcdOperQueue;

-(void)startLoalMesher;
-(void)stopLocalMesher;

@end
