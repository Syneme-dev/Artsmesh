//
//  AMPanelView.m
//  UIFramework
//
//  Created by lattesir on 5/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMPanelView.h"

@implementation AMPanelView
{
    NSRect _knobRect;
    NSColor *_knobColor;
    NSPoint _mouseDownLocation;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)awakeFromNib
{
//
//    _knobColor = [NSColor colorWithCalibratedRed:(46)/255.0f
//                                           green:(58)/255.0f
//                                            blue:(75)/255.0f
//                                           alpha:1.0f];
    _knobColor = [NSColor redColor];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    _mouseDownLocation = [self convertPoint:[theEvent locationInWindow]
                                   fromView:nil];
}

- (NSRect)getKnobRect
{
    NSSize size = self.bounds.size;
    return NSMakeRect(size.width - 16, size.height - 16, 16, 16);
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if (NSPointInRect(_mouseDownLocation, [self getKnobRect])) {
        NSPoint mouseLocation = [self convertPoint:[theEvent locationInWindow]
                                          fromView:nil];
        CGFloat deltaX = mouseLocation.x - _mouseDownLocation.x;
        CGFloat deltaY = mouseLocation.y - _mouseDownLocation.y;
//        _knobRect = NSOffsetRect(_knobRect, deltaX, deltaY);
        NSSize frameSize = self.frame.size;
        frameSize.width += deltaX;
        frameSize.height += deltaY;
        [self setFrameSize:frameSize];
    } else {
        [super mouseDragged:theEvent];
    }
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
//    [[NSColor colorWithWhite:0.22 alpha:1.0] set];
//    [NSBezierPath fillRect:self.bounds];
    [_knobColor set];
    NSRect rect = [self getKnobRect];
    [NSBezierPath fillRect:rect];
}


@end
