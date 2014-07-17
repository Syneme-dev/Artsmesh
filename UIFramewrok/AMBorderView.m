//
//  AMBorderView.m
//  DemoUI
//
//  Created by lattesir on 7/17/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMBorderView.h"



@implementation AMBorderView

- (id)initWithView:(NSView *)view
{
    if (!view)
        return nil;
    
    self = [super init];
    if (self) {
        NSRect rect = NSZeroRect;
        rect.size = view.frame.size;
        rect.size.width += BORDER_THICKNESS * 2;
        rect.size.height += BORDER_THICKNESS * 2;
        [self setFrame:rect];
        [view setFrameOrigin:NSMakePoint(BORDER_THICKNESS, BORDER_THICKNESS)];
        [self addSubview:view];
    }
    return self;
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.15 alpha:1.0] set];
    NSRectFill(self.bounds);
}

@end
