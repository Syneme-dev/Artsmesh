//
//  AMPixel.m
//  DemoUI
//
//  Created by Brad Phillips on 9/11/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMPixel.h"

@implementation AMPixel

- (instancetype)initWithIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        _index = index;
        _peerIndex = -1;
        _dotColor = [NSColor colorWithCalibratedRed:0.25
                                              green:0.25
                                               blue:0.2588
                                              alpha:1.0];
        _outerCircleColor = [NSColor colorWithCalibratedRed:0.27
                                                      green:0.3686
                                                       blue:0.494
                                                      alpha:1.0];
        _innerCircleColor = [NSColor colorWithCalibratedRed:0.23
                                                      green:0.2745
                                                       blue:0.32
                                                      alpha:1.0];
        _state = AMPixelStateNormal;
    }
    return self;
}


- (void)drawWithCenterAt:(NSPoint)p
{
    if (self.state == AMPixelStateNormal) {
        NSBezierPath *dot = [NSBezierPath bezierPath];
        [dot appendBezierPathWithArcWithCenter:p
                                        radius:AMPixelDotRadius
                                    startAngle:0
                                      endAngle:360];
        [self.dotColor setFill];
        [dot fill];
    } else {
        // draw outer circle
        [self.outerCircleColor setStroke];
        NSBezierPath *outerCircle = [NSBezierPath bezierPath];
        [outerCircle appendBezierPathWithArcWithCenter:p
                                                radius:AMPixelCircleRadius
                                            startAngle:0
                                              endAngle:360];
        outerCircle.lineWidth = 2.0;
        [outerCircle stroke];
        // draw inner circle
        [self.innerCircleColor set];
        NSBezierPath *innerCircle = [NSBezierPath bezierPath];
        [innerCircle appendBezierPathWithArcWithCenter:p
                                                radius:(AMPixelCircleRadius - 5.0)
                                            startAngle:0
                                              endAngle:360];
        if (self.state == AMPixelStateConnecting) {
            innerCircle.lineWidth = 1.0;
            [innerCircle stroke];
        } else {
            [innerCircle fill];
        }
    }
}

@end
