//
//  AMChannel.m
//  RoutePanel
//
//  Created by lattesir on 9/5/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMChannel.h"

@implementation AMChannel

- (instancetype)init
{
    return [self initWithIndex:NSNotFound];
}

- (instancetype)initWithIndex:(NSUInteger)index
{
    self = [super init];
    if (self) {
        _index = index;
        _type = AMPlaceholderChannel;
        _deviceID = nil;
        _channelName = nil;
        _peerIndexes = [[NSMutableIndexSet alloc] init];
    }
    return self;
}

@end
