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
	[super drawRect:dirtyRect];
}



- (BOOL) acceptsFirstMouse:(NSEvent *)e {
    return YES;
}

- (void)mouseDown:(NSEvent *) e {
    self.lastDragLocation = [[self superview] convertPoint:[e locationInWindow] fromView:nil];
    
}

- (void)mouseDragged:(NSEvent *)theEvent {
    float pixelHeightAdjustment=2;
    //Note: We're working only in the superview's coordinate space, so we always convert.
    NSPoint newDragLocation = [[self superview] convertPoint:[theEvent locationInWindow] fromView:nil];
    NSPoint thisOrigin = [self frame].origin;
    thisOrigin.x += (-self.lastDragLocation.x + newDragLocation.x);
    thisOrigin.y += (-self.lastDragLocation.y + newDragLocation.y);
    NSRect  windowFrame = [self.window frame];
    NSRect  viewFrame = [self frame];
    float topBarHeight=40.0f;
    //Note: Don't let window get dragged up under the top bar
        if( (thisOrigin.y+viewFrame.size.height+topBarHeight) > (windowFrame.size.height+pixelHeightAdjustment) ){
thisOrigin.y=(windowFrame.size.height-viewFrame.size.height)-topBarHeight+pixelHeightAdjustment;
        }
    
    float leftBarSpacing=30.0f;
    if( (thisOrigin.x) < (40+leftBarSpacing) ){
        thisOrigin.x=40+leftBarSpacing;
    }

    [self setFrameOrigin:thisOrigin];
    self.lastDragLocation = newDragLocation;
}

@end
