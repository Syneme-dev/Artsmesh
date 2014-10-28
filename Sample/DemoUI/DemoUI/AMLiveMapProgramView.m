//
//  AMLiveMapProgramView.m
//  DemoUI
//
//  Created by Brad Phillips on 10/27/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMLiveMapProgramView.h"

@implementation AMLiveMapProgramView

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
    
    // Drawing code here.
    [self.layer setBackgroundColor:[[NSColor colorWithCalibratedRed:0.14
                                                              green:0.14
                                                               blue:0.14
                                                              alpha:0.95] CGColor]];
    
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
