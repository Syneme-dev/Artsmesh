//
//  AMETCDDataSource.h
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMETCDOperation.h"


@class AMETCDDestination;

@interface AMETCDDataSource : NSObject<AMETCDOperationDelegate>

@property NSString* name;
@property NSString* ip;
@property NSString* port;
@property NSMutableArray* destinations;
@property int changeIndex;
@property BOOL watching;

-(id)init:(NSString*)name ip:(NSString*)ip port:(NSString*)port;
-(void)watch;
-(void)stopWatch;
-(void)addDestination:(AMETCDDestination*)dest;
-(void)removeDestination:(AMETCDDestination *)dest;

@end
