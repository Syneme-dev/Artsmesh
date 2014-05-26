//
//  AMPanelView.m
//  UIFramework
//
//  Created by lattesir on 5/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMPanelView.h"

@interface AMPanelView ()

@property(nonatomic) NSRect knobRectLeft;
@property(nonatomic) NSRect knobRectRight;

@end

@implementation AMPanelView
{
    NSColor *_knobColor;
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

    _knobColor = [NSColor colorWithCalibratedRed:(46)/255.0f
                                           green:(58)/255.0f
                                            blue:(75)/255.0f
                                           alpha:1.0f];
}

- (NSRect)knobRectRight
{
    return NSMakeRect(self.bounds.size.width - 16,
                      self.bounds.size.height - 16, 16, 16);
}

- (NSRect)knobRectLeft
{
    return NSMakeRect(0, self.bounds.size.height - 16, 16, 16);
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint mouseDownLocation = [self convertPoint:[theEvent locationInWindow]
                                          fromView:nil];
    if (NSPointInRect(mouseDownLocation, self.knobRectRight))
        self.dragBehavior = AMDragForResizing;
    [super mouseDown:theEvent];
}

- (void)resizeByDraggingLocation:(NSPoint)location
{
    location = [self convertPoint:location fromView:nil];
    [self setFrameSize:NSMakeSize(location.x + 8, location.y + 8)];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    self.dragBehavior = AMDragForMoving;
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor colorWithWhite:0.22 alpha:1.0] set];
    [NSBezierPath fillRect:self.bounds];
    [_knobColor set];
    [NSBezierPath fillRect:self.knobRectLeft];
    [NSBezierPath fillRect:self.knobRectRight];
}


@end
