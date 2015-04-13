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

    CGFloat width  = [self bounds].size.width;
    CGFloat height = [self bounds].size.height;
   
    NSColor *fgColor = [NSColor colorWithCalibratedRed:237/255.0
                                                 green: 28/255.0
                                                  blue: 36/255.0
                                                 alpha:      0.5];
    
 //   NSColor *fgColor = [NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5];
    [fgColor set];
    
    //Be careful about the midBar height and triangle height.
    //If the midBar overlap the triangle,the overlapping part is different from other.
    NSBezierPath* midBar = [NSBezierPath bezierPath];
    [midBar setLineWidth:2];
    [midBar moveToPoint:NSMakePoint(width/2, height-width+1)];
    [midBar lineToPoint:NSMakePoint(width/2, width)];
    [midBar stroke];
    
    
    // To draw two triangles both in the up and down end.
    NSBezierPath* topTriangle = [NSBezierPath bezierPath];
    [topTriangle moveToPoint:NSMakePoint(0, height)];
    [topTriangle lineToPoint:NSMakePoint(width, height)];
    [topTriangle lineToPoint:NSMakePoint(width/2, height-width)];
    [topTriangle fill];
   
    NSBezierPath* bottomTriangle = [NSBezierPath bezierPath];
    [bottomTriangle moveToPoint:NSMakePoint(0, 0)];
    [bottomTriangle lineToPoint:NSMakePoint(width, 0)];
    [bottomTriangle lineToPoint:NSMakePoint(width/2, width+1)];
    [bottomTriangle fill];
}



@end
