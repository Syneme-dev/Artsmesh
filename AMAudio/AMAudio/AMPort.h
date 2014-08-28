//
//  AMPort.h
//  RouterDemo
//
//  Created by lattesir on 8/28/14.
//  Copyright (c) 2014 artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AMPortCircleRadius 10.0
#define AMPortDotRadius    5.0

typedef NS_ENUM(NSUInteger, AMPortState) {
    AMPortStateNormal,
    AMPortStateConnecting,
    AMPortStateConnected
};

@interface AMPort : NSObject

@property(nonatomic) NSInteger index;
@property(nonatomic) NSInteger peerIndex;
@property(nonatomic) AMPortState state;
@property(nonatomic) NSColor *dotColor;
@property(nonatomic) NSColor *outerCircleColor;
@property(nonatomic) NSColor *innerCircleColor;

// designated initializer
- (instancetype)initWithIndex:(NSInteger)index;
- (void)drawWithCenterAt:(NSPoint)p;

@end
