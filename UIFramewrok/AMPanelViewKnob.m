//
//  AMPanelViewKnob.m
//  UIFramework
//
//  Created by lattesir on 5/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMPanelViewKnob.h"

@implementation AMPanelViewKnob
{
    NSEvent *_mouseDownEvent;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    _mouseDownEvent = theEvent;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint oldPosition = [self convertPoint:[_mouseDownEvent locationInWindow]
                                    fromView:self.superview];
    NSPoint newPosition = [self convertPoint:[theEvent locationInWindow]
                                    fromView:self.superview];
 
    CGFloat deltaX = newPosition.x - oldPosition.x;
    CGFloat deltaY = newPosition.y - oldPosition.y;
    NSRect rect = self.superview.frame;
    self.superview.frame = NSInsetRect(rect, deltaX, deltaY);
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor colorWithCalibratedRed:(46)/255.0f green:(58)/255.0f blue:(75)/255.0f alpha:1.0f] set];
    NSRectFill([self bounds]);
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

@end
