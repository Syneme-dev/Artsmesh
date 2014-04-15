//
//  AMETCDWatchOperation.h
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDOperation.h"

@interface AMETCDWatchOperation : AMETCDOperation

@property int currentIndex;
@property int expectedIndex;
@property NSString* path;

-(id)init:(NSString*)ip
     port:(NSString*)port
     path:(NSString*)path
    index:(int)index;

@end
