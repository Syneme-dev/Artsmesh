//
//  AMETCDDataSource.h
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMETCDOperationDelegate.h"


@class AMETCDDestination;

@interface AMETCDDataSource : NSObject<AMETCDOperationDelegate>

@property NSString* name;
@property NSString* ip;
@property NSString* port;
@property NSMutableArray* destinations;

-(id)init:(NSString*)name ip:(NSString*)ip port:(NSString*)port;
-(void)watch;
-(void)addDestination:(AMETCDDestination*)dest;
-(void)removeDestination:(AMETCDDestination *)dest;
-(void)addUserToDataSource:(NSString*)fullUserName fullGroupName:(NSString*)groupName;

@end
