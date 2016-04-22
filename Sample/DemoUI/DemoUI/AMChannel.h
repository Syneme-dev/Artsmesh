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

 NSString* kSenderRole;
 NSString* kReceiverRole;
 NSString* kDualRole;
@interface AMChannel : NSObject

@property(nonatomic) AMChannelType type;
@property(nonatomic) NSString *deviceID;
@property(nonatomic) NSString *processID;
@property(nonatomic) NSString *channelName;
@property(nonatomic) NSUInteger index;
@property(nonatomic) NSMutableIndexSet *peerIndexes;

// designated initializer
- (instancetype)initWithIndex:(NSUInteger)index;

-(NSString*)channelFullName;

@end

#define START_INDEX     18
#define LAST_INDEX      48
#define INDEX_INTERVAL  6

@interface AMVideoDevice : NSObject
@property   NSString*           processID;
@property   NSString*           deviceID;
@property   NSString*           deviceName;
@property   NSMutableArray*     channels;
@property   NSUInteger          index;
@property   NSString*           role;
@property   NSUInteger          validCount;
@end
