//
//  AMPixel.h
//  DemoUI
//
//  Created by Brad Phillips on 9/11/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AMPixelCircleRadius 10.0
#define AMPixelDotRadius    5.0

typedef NS_ENUM(NSUInteger, AMPixelState) {
    AMPixelStateNormal,
    AMPixelStateConnecting,
    AMPixelStateConnected
};

@interface AMPixel : NSObject

@property(nonatomic) NSInteger index;
@property(nonatomic) NSInteger peerIndex;
@property(nonatomic) AMPixelState state;
@property(nonatomic) NSColor *dotColor;
@property(nonatomic) NSColor *outerCircleColor;
@property(nonatomic) NSColor *innerCircleColor;

// designated initializer
- (instancetype)initWithIndex:(NSInteger)index;
- (void)drawWithCenterAt:(NSPoint)p;

@end
