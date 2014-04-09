//
//  AMETCDDestination.h
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMETCDApi/AMETCD.h"
#import "AMETCDDataSource.h"

@interface AMETCDDestination : NSObject

@property NSString* name;


-(void)handleQueryEtcdFinished:(AMETCDResult*)res source:(AMETCDDataSource*)source;

-(void)handleWatchEtcdFinished:(AMETCDResult*)res source:(AMETCDDataSource*)source;

@end
