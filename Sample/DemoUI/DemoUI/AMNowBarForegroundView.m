//
//  AMNowBarForegroundView.m
//  Artsmesh
//
//  Created by whiskyzed on 3/19/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMNowBarForegroundView.h"

@implementation AMNowBarForegroundView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSRect  bounds      = [self bounds];
    NSPoint nowBarStart = NSMakePoint(bounds.size.width / 3, 0);
    NSPoint nowBarEnd   = NSMakePoint(bounds.size.width / 3, bounds.size.height);
    NSBezierPath* path       = [NSBezierPath bezierPath];
    [path setLineWidth:3];
    [path moveToPoint:nowBarStart];
    [path lineToPoint:nowBarEnd];
    
    NSColor *fgColor = [NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5];
    [fgColor setStroke];
    
    [path stroke];
 }

@end
