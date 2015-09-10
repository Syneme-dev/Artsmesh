//
//  AMVisualView.m
//  Artsmesh
//
//  Created by whiskyzed on 8/4/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMVisualView.h"
static const int Up = 5;
static const int Bottom = 0;


@implementation AMVisualView

- (void) drawBoundaryWithWidth : (CGFloat) width
               withHeight      : (CGFloat) height
{
    // Draw the upper blue line.
    NSRect lineRect = NSMakeRect(0,  height - Up, width, 2);
    NSBezierPath* path = [NSBezierPath bezierPathWithRect:lineRect];
    [[NSColor colorWithCalibratedRed:(42)/255.0f
                               green:(48)/255.0f
                                blue:(57)/255.0f
                               alpha:1.0f]     set];
    [path fill];
    
    // Draw the down blue line.
    NSRect bottomLineRect = NSMakeRect(0,  Bottom, width, 2);
    NSBezierPath* bottomPath = [NSBezierPath bezierPathWithRect:bottomLineRect];
    [bottomPath fill];
    
    // Draw the middle blue line.
    CGFloat midHPosition = (height - Up + Bottom) / 2;
    NSRect middleHRect = NSMakeRect(0,  midHPosition, width, 2);
    NSBezierPath* middleHPath = [NSBezierPath bezierPathWithRect:middleHRect];

    [middleHPath fill];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    CGFloat width  = [self bounds].size.width;
    CGFloat height = [self bounds].size.height;

    [self drawBoundaryWithWidth:width withHeight:height];
     CGFloat midHPosition = (height + Up - Bottom) / 2;
    
    [self drawHorizontalAuxiliary:width YStart:0 YEnd:midHPosition withCount:2];
    [self drawHorizontalAuxiliary:width YStart:midHPosition YEnd:height withCount:2];
 
    [self drawVerticalAuxiliary:height XStart:0 XEnd:width withCount:4];
}


- (void) drawHorizontalAuxiliary : (CGFloat) width
                YStart           : (CGFloat) YStart
                YEnd             : (CGFloat) YEnd
                withCount        : (NSInteger) count
{
    CGFloat delta = (YEnd - YStart)/(count + 1);
    
    for (int i = 0; i < count; i++) {
        CGFloat height = YStart + delta * (i + 1);
        NSBezierPath *auxiliaryLine = [NSBezierPath bezierPath];
        NSPoint startPoint = NSMakePoint(0,    height);
        NSPoint endPoint   = NSMakePoint(width, height);
        [auxiliaryLine moveToPoint:startPoint];
        [auxiliaryLine lineToPoint:endPoint];
        auxiliaryLine.lineWidth = 1.0;
        
        [[NSColor colorWithCalibratedRed:(40)/255.0f
                                   green:(43)/255.0f
                                    blue:(47)/255.0f
                                   alpha:1.0f]     setStroke];
        [auxiliaryLine stroke];
    }
}

- (void) drawVerticalAuxiliary   : (CGFloat) height
                XStart           : (CGFloat) YStart
                XEnd             : (CGFloat) YEnd
                withCount        : (NSInteger) count
{
    CGFloat delta = (YEnd - YStart)/(count + 1);
    for (int i = 0; i < count; i++) {
        CGFloat width = YStart + delta * (i + 1);
        
        NSBezierPath *auxiliaryLine = [NSBezierPath bezierPath];
        
        NSPoint startPoint = NSMakePoint(width, 0);
        NSPoint endPoint   = NSMakePoint(width, height);
        [auxiliaryLine moveToPoint:startPoint];
        [auxiliaryLine lineToPoint:endPoint];
        auxiliaryLine.lineWidth = 1.0;
        
        [[NSColor colorWithCalibratedRed:(40)/255.0f
                                   green:(43)/255.0f
                                    blue:(47)/255.0f
                                   alpha:1.0f]     setStroke];
        [auxiliaryLine stroke];
    }
}

@end
