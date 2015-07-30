//
//  AMFakeBox.m
//  UIFramework
//
//  Created by whiskyzed on 7/30/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMFakeBox.h"

@implementation AMFakeBox
{
    NSColor *_knobColor;
    NSRect _rectForPromptLine;
}

- (void)drawRect:(NSRect)dirtyRect
{
 //   [self.backgroundColor set];
//    [NSBezierPath fillRect:self.bounds];
    [[NSColor clearColor] set];
    NSRectFill(self.bounds);
    [[NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.15 alpha:1.0] set];
    NSBezierPath *roundedRect = [NSBezierPath bezierPathWithRoundedRect:self.bounds
                                                                xRadius:10
                                                                yRadius:10];
    [roundedRect fill];

    [[NSColor colorWithCalibratedRed:(46)/255.0f
                               green:(58)/255.0f
                                blue:(75)/255.0f
                               alpha:1.0f] set];
    [NSBezierPath fillRect:self.knobRectLeft];
    [NSBezierPath fillRect:self.knobRectRight];
}

- (NSRect)knobRectRight
{
    NSRect rect  = [self bounds];
    CGSize size = rect.size;
    return NSMakeRect(size.width - 80, 5, 16, 16);
}

- (NSRect)knobRectLeft
{
    return NSMakeRect(0, 5, 16, 16);
}


@end
