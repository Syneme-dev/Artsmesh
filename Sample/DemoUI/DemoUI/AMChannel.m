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

-(void)sortChannels
{
    NSMutableArray* sortedChannels = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.channels count]; i++) {
        
        AMChannel* chann = self.channels[i];
        if (chann.type == AMDestinationChannel) {
            [sortedChannels addObject:chann];
        }else{
            
            BOOL bFind = NO;
            for (int j = 0; j < [sortedChannels count]; j++) {
                AMChannel* existCh = sortedChannels[j];
                if (existCh.type == AMDestinationChannel) {
                    [sortedChannels insertObject:chann atIndex:j];
                    bFind = YES;
                    break;
                }
            }
            
            if (!bFind) {
                [sortedChannels addObject:chann];
            }
        }
    }
    
    self.channels = sortedChannels;
}

@end

