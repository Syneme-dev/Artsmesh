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

-(id)init:(NSString*)ip
     port:(NSString*)port
    index:(int)index;

@end
