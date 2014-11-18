//
//  AMVideoMixerBackgroundView.m
//  AMVideo
//
//  Created by robbin on 11/17/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import "AMVideoMixerBackgroundView.h"

@interface AMVideoMixerBackgroundView ()
@property (strong, nonatomic) NSColor *backgroundColor;
@property (strong, nonatomic) NSColor *borderColor;
@end


@implementation AMVideoMixerBackgroundView

- (void)drawRect:(NSRect)dirtyRect {
    NSBezierPath *rect = [NSBezierPath bezierPathWithRect:self.bounds];
    [self.backgroundColor setFill];
    [rect fill];
    if (self.hasBorder) {
        [self.borderColor setStroke];
        rect.lineWidth = 6.0;
        [rect stroke];
    }
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (NSColor *)backgroundColor
{
    if (!_backgroundColor) {
        _backgroundColor = [NSColor colorWithCalibratedRed:0.137
                                                     green:0.137
                                                      blue:0.137
                                                     alpha:1.0];
    }
    return _backgroundColor;
}


- (NSColor *)borderColor
{
    if (!_borderColor) {
        _borderColor = [NSColor colorWithCalibratedRed:0.176
                                                 green:0.227
                                                  blue:0.294
                                                 alpha:1.0];
    }
    return _borderColor;
}

- (void)setHasBorder:(BOOL)hasBorder
{
    _hasBorder = hasBorder;
    [self setNeedsDisplay:YES];
}

@end
