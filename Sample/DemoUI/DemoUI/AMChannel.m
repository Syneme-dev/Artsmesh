//
//  AMChannel.m
//  RoutePanel
//
//  Created by lattesir on 9/5/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMChannel.h"


@implementation AMDevice

@end

 NSString* kSenderRole     = @"SENDER";
 NSString* kReceiverRole   = @"RECEIVER";
 NSString* kDualRole       = @"DUAL";

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
        _processID = nil;
        _channelName = nil;
        _peerIndexes = [[NSMutableIndexSet alloc] init];
    }
    return self;
}

-(NSString*)channelFullName
{
    return [NSString stringWithFormat:@"%@:%@", self.deviceID, self.channelName];
}

@end

@implementation AMVideoDevice

- (instancetype)init
{
    self = [super init];
    if (self) {
        _channels = [[NSMutableArray alloc] init];
    }
    return self;
}

@end



