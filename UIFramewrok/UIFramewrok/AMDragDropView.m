//
//  AMDragDropView.m
//  UIFramewrok
//
//  Created by xujian on 3/7/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMDragDropView.h"

@implementation AMDragDropView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor colorWithCalibratedRed:(48+12)/255.0f green:(64+11)/255.0f blue:(80+14)/255.0f alpha:1.0f] set];
    NSRectFill([self bounds]);
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}



- (BOOL) acceptsFirstMouse:(NSEvent *)e {
    return YES;
}

- (void)mouseDown:(NSEvent *) e {
    
    // Convert to superview's coordinate space
    self.lastDragLocation = [[self superview] convertPoint:[e locationInWindow] fromView:nil];
    
}

- (void)mouseDragged:(NSEvent *)theEvent {
    
    // We're working only in the superview's coordinate space, so we always convert.
    NSPoint newDragLocation = [[self superview] convertPoint:[theEvent locationInWindow] fromView:nil];
    NSPoint thisOrigin = [self frame].origin;
    thisOrigin.x += (-self.lastDragLocation.x + newDragLocation.x);
    thisOrigin.y += (-self.lastDragLocation.y + newDragLocation.y);
    [self setFrameOrigin:thisOrigin];
    self.lastDragLocation = newDragLocation;
}

@end
