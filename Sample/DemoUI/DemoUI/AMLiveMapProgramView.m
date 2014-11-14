//
//  AMLiveMapProgramView.m
//  DemoUI
//
//  Created by Brad Phillips on 10/27/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMLiveMapProgramView.h"

#define UI_Color_gray [NSColor colorWithCalibratedRed:0.152 green:0.152 blue:0.152 alpha:1]

@implementation AMLiveMapProgramView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.backgroundColor = [NSColor redColor];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.

    /**
    NSRect contentR = self.bounds;
    
    [NSGraphicsContext saveGraphicsState];
    
    [[NSColor grayColor] set];
    NSBezierPath *btnLine = [NSBezierPath bezierPath];
    [btnLine moveToPoint:NSMakePoint(contentR.origin.x, contentR.origin.y + 36)];
    [btnLine lineToPoint:NSMakePoint(contentR.origin.x + contentR.size.width, contentR.origin.y + 36)];
    [btnLine moveToPoint:NSMakePoint(contentR.origin.x + contentR.size.width / 2, contentR.origin.y + 36)];
    [btnLine lineToPoint:NSMakePoint(contentR.origin.x + contentR.size.width / 2, contentR.origin.y)];
    [btnLine stroke];
     
    [NSGraphicsContext restoreGraphicsState];
    **/
    
    [self.layer setBackgroundColor:(__bridge CGColorRef)(UI_Color_gray)];
    
    //[self.backgroundColor set];
    //[NSBezierPath fillRect:self.bounds];
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}

-(void)mouseDown:(NSEvent *)theEvent
{
    return;
}

@end
