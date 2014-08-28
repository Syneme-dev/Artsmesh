//
//  AMRouterView.m
//  RouterDemo
//
//  Created by lattesir on 8/25/14.
//  Copyright (c) 2014 artsmesh. All rights reserved.
//

#import "AMRouterView.h"
#import "AMPort.h"

@interface AMRouterView ()
{
    NSPoint _center;
    CGFloat _radius;
    NSInteger _portIndex;
}

@property (nonatomic) NSColor *backgroundColor;
@property (nonatomic) NSArray *ports;

@end


@implementation AMRouterView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    _backgroundColor = [NSColor colorWithCalibratedRed:0.2
                                                 green:0.2
                                                  blue:0.2
                                                 alpha:1.0];
    int numberOfPorts = 72;
    NSMutableArray *allPorts = [NSMutableArray arrayWithCapacity:numberOfPorts];
    for (int i = 0; i < numberOfPorts; i++) {
        [allPorts addObject:[[AMPort alloc] initWithIndex:i]];
    }
    _ports = [allPorts copy];
    _portIndex = -1;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self.backgroundColor set];
    NSRectFill(self.bounds);
    
    NSRect rect = NSInsetRect(self.bounds, NSWidth(self.bounds) / 16.0,
                              NSHeight(self.bounds) / 16.0);
    _radius = MIN(NSWidth(rect) / 2.0, NSHeight(rect) / 2.0);
    _center = NSMakePoint(NSMidX(rect), NSMidY(rect));
    
    for (int i = 0; i < self.ports.count; i++) {
        AMPort *port = self.ports[i];
        if (port.state == AMPortStateConnected && port.index < port.peerIndex) {
            NSBezierPath *bezierPath = [NSBezierPath bezierPath];
            [bezierPath moveToPoint:[self centerOfPort:port.index]];
            [bezierPath curveToPoint:[self centerOfPort:port.peerIndex]
                       controlPoint1:_center
                       controlPoint2:_center];
            if (port.index == _portIndex) {
                bezierPath.lineWidth = 12.0;
                [[NSColor colorWithRed:0.6 green:1.0 blue:1.0 alpha:0.2] setStroke];
                [bezierPath stroke];
                bezierPath.lineWidth = 1.0;
                //[[NSColor lightGrayColor] setStroke];
                [[NSColor greenColor] setStroke];
                [bezierPath stroke];
            } else {
                bezierPath.lineWidth = 1.0;
               // [[NSColor grayColor] setStroke];
                [[NSColor greenColor] setStroke];
                [bezierPath stroke];
            }
        }
        [port drawWithCenterAt:[self centerOfPort:i]];
    }
}

- (NSPoint)centerOfPort:(NSInteger)portIndex
{
    NSAssert(portIndex >= 0 && portIndex < self.ports.count, @"invalid argument");
    
    CGFloat radian = portIndex * 2 * M_PI / self.ports.count;
    return NSMakePoint(_radius * cos(radian) + _center.x,
                       _radius * sin(radian) + _center.y);
}

- (void)mouseUp:(NSEvent *)theEvent
{
    static AMPort * __weak previousConnectingPort = nil;
    
    _portIndex = -1;
    
    NSInteger index = [self testMouseUpOccuredOnPort:theEvent];
    if (index != -1) {
        AMPort *port = self.ports[index];
        switch (port.state) {
            case AMPortStateNormal:
                if (previousConnectingPort) {
                    port.state = AMPortStateConnected;
                    port.peerIndex = previousConnectingPort.index;
                    previousConnectingPort.state = AMPortStateConnected;
                    previousConnectingPort.peerIndex = port.index;
                    previousConnectingPort = nil;
                } else {
                    port.state = AMPortStateConnecting;
                    previousConnectingPort = port;
                }
                break;
            case AMPortStateConnecting:
                port.state = AMPortStateNormal;
                previousConnectingPort = nil;
            default:
                break;
        }
    } else {
        _portIndex = [self testMouseUpOccuredOnPath:theEvent];
    }
    
    self.needsDisplay = YES;
}

- (NSInteger)testMouseUpOccuredOnPort:(NSEvent *)mouseUpEvent
{
    NSPoint p = [self convertPoint:[mouseUpEvent locationInWindow]
                          fromView:nil];
    CGFloat r = hypot(p.x - _center.x, p.y - _center.y);
    if (fabs(r - _radius) >= AMPortCircleRadius)
        return -1;
    CGFloat theta = atan2(p.y - _center.y, p.x - _center.x);
    if (theta < 0)
        theta += 2 * M_PI;
    int portIndex = (int)(theta * self.ports.count / (2 * M_PI) + 0.5) % self.ports.count;
    NSPoint portCenter = [self centerOfPort:portIndex];
    r = hypot(p.x - portCenter.x, p.y - portCenter.y);
    if (r >= AMPortCircleRadius)
        return -1;
    else
        return portIndex;
}

- (NSInteger)testMouseUpOccuredOnPath:(NSEvent *)mouseUpEvent
{
    NSPoint p = [self convertPoint:[mouseUpEvent locationInWindow]
                          fromView:nil];
    if (hypot(p.x - _center.x, p.y - _center.y) >= (_radius - AMPortCircleRadius))
        return -1;
    for (AMPort *port in self.ports) {
        if (port.state == AMPortStateConnected && port.index < port.peerIndex) {
            CGPoint portCenter = NSPointToCGPoint([self centerOfPort:port.index]);
            CGPoint peerPortCenter = NSPointToCGPoint([self centerOfPort:port.peerIndex]);
            CGMutablePathRef bezierPath = CGPathCreateMutable();
            CGPathMoveToPoint(bezierPath, NULL, portCenter.x, portCenter.y);
            CGPathAddCurveToPoint(bezierPath, NULL, _center.x, _center.y, _center.x,
                                  _center.y, peerPortCenter.x, peerPortCenter.y);
            CGPathRef hitTestArea = CGPathCreateCopyByStrokingPath(bezierPath, NULL,
                                        20.0, NSButtLineCapStyle, NSRoundLineJoinStyle, 10.0);
            CGPathRelease(bezierPath);
            if (CGPathContainsPoint(hitTestArea, NULL, p, false)) {
                CGPathRelease(hitTestArea);
                return port.index;
            }
            CGPathRelease(hitTestArea);
        }
    }
    return -1;
}


@end
