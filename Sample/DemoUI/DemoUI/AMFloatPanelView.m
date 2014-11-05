//
//  AMFloatPanel.m
//  DemoUI
//
//  Created by Brad Phillips on 11/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMFloatPanelView.h"
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

- (void)mouseUp:(NSEvent *)theEvent
{
    self.isDragging = NO;
    
    if (self.inFullScreenMode)
        return;
    
    if (self.resizing) {
        self.resizing = NO;
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
    //[NSBezierPath fillRect:self.knobRectLeft];
    //[NSBezierPath fillRect:self.knobRectRight];
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
