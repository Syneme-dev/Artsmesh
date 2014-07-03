//
//  BlueBackgroundView.m
//  UIFramewrok
//
//  Created by xujian on 3/31/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "BlueBackgroundView.h"

@implementation BlueBackgroundView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

/*
- (void)mouseDown:(NSEvent *)theEvent
{
    [self.superview mouseDown:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    [self.superview mouseDragged:theEvent];
}
 */

- (void)drawRect:(NSRect)dirtyRect
{
    NSColor *color= [NSColor colorWithCalibratedRed:(46)/255.0f green:(58)/255.0f blue:(75)/255.0f alpha:1.0f] ;
    [color set];
    NSRectFill([self bounds]);
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

@end
