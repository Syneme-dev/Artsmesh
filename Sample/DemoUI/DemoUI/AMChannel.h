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

#define SELF_COUNT      11  // The count of dots in SELF area.
#define START_INDEX     12  // Beside SELF, the first index can be used.
#define LAST_INDEX      48  // Beside SELF, the last  index can be used.
#define INDEX_INTERVAL  2

@interface AMDevice : NSObject
@property(nonatomic) NSString *deviceID;
@property(nonatomic) NSString *deviceName;
@property(nonatomic) BOOL removable;
@property(nonatomic) NSRange channelIndexRange;
@property(nonatomic) NSPoint closeButtonCenter;
@end


@interface AMVideoDevice : NSObject
@property   NSString*           processID;
@property   NSString*           deviceID;
@property   NSString*           deviceName;
@property   NSMutableArray*     channels;
@property   NSUInteger          index;
@property   NSString*           role;
@property   NSUInteger          validCount;
@end
