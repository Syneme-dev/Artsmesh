//
//  AMNowBarView.m
//  Artsmesh
//
//  Created by whiskyzed on 3/23/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMNowBarView.h"

@implementation AMNowBarView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
/*
    NSRect  bounds      = [self bounds];
    NSPoint nowBarStart = NSMakePoint(bounds.size.width / 3, 0);
    NSPoint nowBarEnd   = NSMakePoint(bounds.size.width / 3, bounds.size.height);
    NSBezierPath* path       = [NSBezierPath bezierPath];
    [path setLineWidth:3];
    [path moveToPoint:nowBarStart];
    [path lineToPoint:nowBarEnd];     
    [path fill];
    */
    // To draw two triangles both in the front and below end
    CGFloat width  = [self bounds].size.width;
    CGFloat height = [self bounds].size.height;
    
    NSColor *fgColor = [NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5];
    [fgColor set];
    
    NSBezierPath* midBar = [NSBezierPath bezierPath];
    [midBar setLineWidth:2];
    [midBar moveToPoint:NSMakePoint(width/2, height-width+1)];
    [midBar lineToPoint:NSMakePoint(width/2, width)];
    [midBar stroke];
    
    NSBezierPath* upperTriangle = [NSBezierPath bezierPath];
    [upperTriangle moveToPoint:NSMakePoint(0, height)];
    [upperTriangle lineToPoint:NSMakePoint(width, height)];
    [upperTriangle lineToPoint:NSMakePoint(width/2, height-width)];
    [upperTriangle fill];
   
    
    NSBezierPath* lowerTriangle = [NSBezierPath bezierPath];
    [lowerTriangle moveToPoint:NSMakePoint(0, 0)];
    [lowerTriangle lineToPoint:NSMakePoint(width, 0)];
    [lowerTriangle lineToPoint:NSMakePoint(width/2, width+1)];
    [lowerTriangle fill];

//    NSRectFill(self.bounds);
}



@end
