//
//  AMPopUpMenuItem.m
//  MyPopUpTest
//
//  Created by 王 为 on 7/31/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import "AMPopUpMenuItem.h"

@implementation AMPopUpMenuItem
{
    BOOL _mouseOver;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.backgroupColor = [NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.15 alpha:1];
        self.mouseOverColor = [NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:1];
        self.title = @"";
        self.textColor = [NSColor whiteColor];
        self.font = [NSFont fontWithName: @"FoundryMonoline-Bold" size: self.font.pointSize];
        [self addTrackingRect:self.bounds owner:self userData:nil assumeInside:NO];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    [NSGraphicsContext saveGraphicsState];
    
    //Drawing background
    
    NSBezierPath* border = [NSBezierPath bezierPathWithRect:self.bounds];
    if (_mouseOver) {
        [self.mouseOverColor set];
    }else{
        [self.backgroupColor set];
    }
    
    [border fill];
    
    // Drawing title
    NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] init];
    
    if (self.font) {
        textAttributes[NSFontAttributeName] = self.font;
    }
    
    if (self.textColor) {
        textAttributes[NSForegroundColorAttributeName] = self.textColor;
    }
    
    NSSize fontSize = [self.title sizeWithAttributes:textAttributes];
    NSPoint titleLocation = NSMakePoint(10, (self.bounds.size.height - fontSize.height) /2);
    [self.title drawAtPoint:titleLocation withAttributes:textAttributes];
    
    [NSGraphicsContext restoreGraphicsState];
}

-(void)mouseEntered:(NSEvent *)theEvent
{
    _mouseOver = YES;
    [self setNeedsDisplay:YES];
}

-(void)mouseExited:(NSEvent *)theEvent
{
    _mouseOver = NO;
    [self setNeedsDisplay:YES];
}

-(void)mouseDown:(NSEvent *)theEvent
{
    [self.delegate itemSelected:self];
}


@end
