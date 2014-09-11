//
//  AMChannel.h
//  RoutePanel
//
//  Created by lattesir on 9/5/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AMChannelType) {
    AMPlaceholderChannel,
    AMSourceChannel,
    AMDestinationChannel
};


@interface AMChannel : NSObject

@property(nonatomic) AMChannelType type;
@property(nonatomic) NSString *deviceID;
@property(nonatomic) NSString *channelName;
@property(nonatomic) NSUInteger index;
@property(nonatomic) NSMutableIndexSet *peerIndexes;

// designated initializer
- (instancetype)initWithIndex:(NSUInteger)index;

@end
