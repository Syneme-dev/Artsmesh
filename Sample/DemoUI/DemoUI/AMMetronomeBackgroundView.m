//
//  AMMetronomeBackgroundView.m
//  DemoUI
//
//  Created by GaoMing on 1/10/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMMetronomeBackgroundView.h"

@implementation AMMetronomeBackgroundView

- (BOOL)isOpaque
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSColor *bgColor = [NSColor colorWithCalibratedRed:0.149 green:0.149 blue:0.149 alpha:1.0];
    [bgColor setFill];
    NSRectFill(self.bounds);
    
    NSAffineTransform *transform = [[NSAffineTransform alloc] init];
    [transform translateXBy:NSMidX(self.bounds) yBy:NSMidY(self.bounds)];
    [transform concat];
    CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) /  2.0;
    NSRect rect = NSMakeRect(-radius, -radius, 2.0 * radius, 2.0 * radius);
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:rect];
    NSColor *circleFillColor = [NSColor colorWithCalibratedRed:0.176 green:0.23 blue:0.298 alpha:1.0];
    [circleFillColor setFill];
    [path fill];
    path = [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(rect, 8, 8)];
    path.lineWidth = 2.0;
    [bgColor setStroke];
    [path stroke];
}

@end
