//
//  AMBackgroundView.m
//  UIFramework
//
//  Created by lattesir on 10/29/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMBackgroundView.h"

@implementation AMBackgroundView
@synthesize backgroundColor = _backgroundColor;

- (void)drawRect:(NSRect)dirtyRect {
    [self.backgroundColor setFill];
    NSRectFill(self.bounds);
}

- (NSColor *)backgroundColor
{
    if (!_backgroundColor) {
        _backgroundColor = [NSColor colorWithCalibratedRed:0.15
                                                     green:0.15
                                                      blue:0.15
                                                     alpha:1.0];
    }
    return _backgroundColor;
}

- (void)setBackgroundColor:(NSColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    [self setNeedsDisplay:YES];
}

@end
