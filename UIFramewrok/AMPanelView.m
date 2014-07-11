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

@property(nonatomic) BOOL resizing;
@property(nonatomic) NSRect knobRectLeft;
@property(nonatomic) NSRect knobRectRight;

@end

@implementation AMPanelView
{
    NSColor *_knobColor;
    NSPoint _offset;
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
    NSPoint p = [theEvent locationInWindow];
    
    if (NSPointInRect([self convertPoint:p fromView:nil], self.knobRectRight)) {
        self.resizing = YES;
    } else if (self.tearedOff) {
        _offset.x = -p.x;
        _offset.y = -p.y;
    } else {
        [super mouseDown:theEvent];
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint p = [theEvent locationInWindow];

    if (self.resizing) {
        p.x += 8;
        p.y -= 8;
        if (!self.tearedOff) {
            p = [self convertPoint:p fromView:nil];
            self.preferredSize = NSMakeSize(p.x, p.y);
        } else {
            NSRect windowFrame = NSZeroRect;
            windowFrame.origin.y = p.y;
            windowFrame.size.width = p.x;
            windowFrame.size.height = (self.window.frame.size.height - p.y);
            windowFrame = [self.window convertRectToScreen:windowFrame];
            [self setFrameSize:windowFrame.size];
            [self.window setFrame:windowFrame display:YES];
        }
    } else if (self.tearedOff) {
        NSRect rect = NSMakeRect(p.x, p.y, 0, 0);
        rect = [self.window convertRectToScreen:rect];
        p = rect.origin;
        NSPoint newOrigin = NSMakePoint(_offset.x + p.x, _offset.y + p.y);
        [self.window setFrameOrigin:newOrigin];
    } else {
        [super mouseDragged:theEvent];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if (self.resizing) {
        self.resizing = NO;
    } else if (self.tearedOff) {
        // do nothing
    } else {
        [super mouseUp:theEvent];
    }
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
