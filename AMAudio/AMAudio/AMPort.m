//
//  AMPort.m
//  RouterDemo
//
//  Created by lattesir on 8/28/14.
//  Copyright (c) 2014 artsmesh. All rights reserved.
//

#import "AMPort.h"

@implementation AMPort

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
        _state = AMPortStateNormal;
    }
    return self;
}


- (void)drawWithCenterAt:(NSPoint)p
{
    if (self.state == AMPortStateNormal) {
        NSBezierPath *dot = [NSBezierPath bezierPath];
        [dot appendBezierPathWithArcWithCenter:p
                                        radius:AMPortDotRadius
                                    startAngle:0
                                      endAngle:360];
        [self.dotColor setFill];
        [dot fill];
    } else {
        // draw outer circle
        [self.outerCircleColor setStroke];
        NSBezierPath *outerCircle = [NSBezierPath bezierPath];
        [outerCircle appendBezierPathWithArcWithCenter:p
                                                radius:AMPortCircleRadius
                                            startAngle:0
                                              endAngle:360];
        outerCircle.lineWidth = 2.0;
        [outerCircle stroke];
        // draw inner circle
        [self.innerCircleColor set];
        NSBezierPath *innerCircle = [NSBezierPath bezierPath];
        [innerCircle appendBezierPathWithArcWithCenter:p
                                                radius:(AMPortCircleRadius - 5.0)
                                            startAngle:0
                                              endAngle:360];
        if (self.state == AMPortStateConnecting) {
            innerCircle.lineWidth = 1.0;
            [innerCircle stroke];
        } else {
            [innerCircle fill];
        }
    }
}

@end
