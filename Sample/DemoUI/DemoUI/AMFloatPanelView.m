//
//  AMFloatPanel.m
//  DemoUI
//
//  Created by Brad Phillips on 11/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMFloatPanelView.h"
#import "UIFramework/AMBox.h"
#import "UIFramework/AMBorderView.h"

#define UI_Color_gray [NSColor colorWithCalibratedRed:0.152 green:0.152 blue:0.152 alpha:1]

@interface AMFloatPanelView ()

@property(nonatomic) BOOL resizing;
@property(nonatomic) NSRect knobRectLeft;
@property(nonatomic) NSRect knobRectRight;

@end

@implementation AMFloatPanelView
{
    NSColor *_knobColor;
    NSPoint _constantVector;
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
        self.borderThickness = 16;
            }
    self.isDragging = NO;
    self.inFullScreenMode = NO;
    self.tearedOff = YES;
    
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
    //NSLog(@"mouse down!");
    if (self.inFullScreenMode)
        return;
    
    NSPoint p = [theEvent locationInWindow];
    
    //NSPoint convertedPoint = [self convertPoint:p fromView:nil];
        
    if (NSPointInRect([self convertPoint:p fromView:nil], self.knobRectRight)) {
        //NSLog(@"clicked on right knob!");
        self.resizing = YES;
        p = [self convertPoint:p fromView:nil];
        _constantVector = NSMakePoint(self.bounds.size.width - p.x,
                                      self.bounds.size.height - p.y);
        if (self.tearedOff) {
            _constantVector.x += BORDER_THICKNESS;
            _constantVector.y *= -1.0;
            _constantVector.y -= BORDER_THICKNESS;
        }
    } else if (self.tearedOff) {
        _constantVector.x = -p.x;
        _constantVector.y = -p.y;
    } else {
        [super mouseDown:theEvent];
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    
    if (self.inFullScreenMode)
        return;
    
    NSPoint p = [theEvent locationInWindow];
    
    if (self.resizing) {
        if (!self.tearedOff) {
            p = [self convertPoint:p fromView:nil];
            p.x += _constantVector.x;
            p.y += _constantVector.y;
            self.preferredSize = NSMakeSize(p.x, p.y);
        } else {
            NSRect rect = NSMakeRect(p.x, p.y, 0, 0);
            rect = [self.window convertRectToScreen:rect];
            p = rect.origin;
            p.x += _constantVector.x;
            p.y += _constantVector.y;
            
            NSPoint topLeft = NSMakePoint(self.window.frame.origin.x,
                                          self.window.frame.origin.y + self.window.frame.size.height);

            CGFloat newWidth = MAX(self.minSizeConstraint.width, p.x - self.window.frame.origin.x);

            CGFloat newHeight = MAX(self.minSizeConstraint.height, topLeft.y - p.y);
            NSRect windowFrame = NSMakeRect(topLeft.x, topLeft.y - newHeight,
                                            newWidth, newHeight);
            
            [self.window setFrame:windowFrame display:YES];
        }
    } else if (self.tearedOff) {
        NSRect rect = NSMakeRect(p.x, p.y, 0, 0);
        rect = [self.window convertRectToScreen:rect];
        p = rect.origin;
        NSPoint newOrigin = NSMakePoint(p.x + _constantVector.x, p.y + _constantVector.y);
        [self.window setFrameOrigin:newOrigin];
    } else {
        [super mouseDragged:theEvent];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    self.isDragging = NO;
    
    if (self.inFullScreenMode)
        return;
    
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
    [self.floatPanelViewController.titleTextField setTextColor:self.floatPanelViewController.panelTitleColor];
    [self.floatPanelViewController.titleTextField setStringValue:self.floatPanelViewController.panelTitle];
        
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
