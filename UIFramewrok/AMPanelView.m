//
//  AMPanelView.m
//  UIFramework
//
//  Created by lattesir on 5/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMPanelView.h"

#define UI_Color_gray [NSColor colorWithCalibratedRed:0.152 green:0.152 blue:0.152 alpha:1]

@interface AMPanelView ()

@property(nonatomic) NSRect knobRectLeft;
@property(nonatomic) NSRect knobRectRight;

@end

@implementation AMPanelView
{
    NSColor *_knobColor;
}

-(void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
//    NSTrackingAreaOptions trackingOptions = NSTrackingEnabledDuringMouseDrag | NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp;
//    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:self.frame options:trackingOptions owner:self userInfo:nil];
//    [self addTrackingArea:trackingArea];
    

}
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        [self setAcceptsTouchEvents:YES];
         self.backgroundColor = UI_Color_gray;
//        self.backgroundColor=[NSColor colorWithWhite:0.22 alpha:1.0];
        
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
   // [self setFrameSize:NSMakeSize(location.x + 8, location.y + 8)];
    self.preferredSize = NSMakeSize(location.x + 8, location.y + 8);
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
    [self.backgroundColor set];
    [NSBezierPath fillRect:self.bounds];
    [_knobColor set];
    [NSBezierPath fillRect:self.knobRectLeft];
    [NSBezierPath fillRect:self.knobRectRight];
    
  

}

- (void)mouseEntered:(NSEvent *)theEvent
{
    self.backgroundColor  = [ NSColor colorWithWhite:0.22 alpha:1.0];
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    self.backgroundColor = UI_Color_gray;
      [self setNeedsDisplay:YES];
}



@end
