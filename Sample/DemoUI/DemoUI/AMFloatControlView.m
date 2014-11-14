//
//  AMFloatControlView.m
//  DemoUI
//
//  Created by Brad Phillips on 11/4/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMFloatControlView.h"

@implementation AMFloatControlView
{
    NSPoint _constantVector;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    AMFloatPanelView *floatPanel = (AMFloatPanelView *)self.superview;
    self.thePanel = floatPanel;
}


- (void)mouseDown:(NSEvent *)theEvent {
    AMFloatPanelView *floatPanel = (AMFloatPanelView *)self.superview;
    floatPanel.isDragging = YES;


    if (self.inFullScreenMode)
        return;
    
    NSPoint p = [theEvent locationInWindow];
    
    if (floatPanel.tearedOff) {
        _constantVector.x = -p.x;
        _constantVector.y = -p.y;
    } else {
        [super mouseDown:theEvent];
    }
    
}


- (void)mouseDragged:(NSEvent *)theEvent {
    AMFloatPanelView *floatPanel = (AMFloatPanelView *)self.superview;
    floatPanel.isDragging = YES;
    
    if (self.inFullScreenMode)
        return;
    
    NSPoint p = [theEvent locationInWindow];
        
    if (floatPanel.tearedOff) {
        NSRect rect = NSMakeRect(p.x, p.y, 0, 0);
        rect = [self.window convertRectToScreen:rect];
        p = rect.origin;
        NSPoint newOrigin = NSMakePoint(p.x + _constantVector.x, p.y + _constantVector.y);
        [self.window setFrameOrigin:newOrigin];
    } else {
        [super mouseDragged:theEvent];
    }
}


- (void)mouseUp:(NSEvent *)theEvent {
    AMFloatPanelView *floatPanel = (AMFloatPanelView *)self.superview;
    floatPanel.isDragging = NO;
}


@end
