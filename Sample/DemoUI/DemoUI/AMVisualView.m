//
//  AMVisualView.m
//  Artsmesh
//
//  Created by whiskyzed on 8/4/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMVisualView.h"

@implementation AMVisualView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    CGFloat width  = [self bounds].size.width;
    CGFloat height = [self bounds].size.height;

    // Draw the upper blue line.
    NSRect lineRect = NSMakeRect(0, height - 10, width, 1);
    NSBezierPath* path = [NSBezierPath bezierPathWithRect:lineRect];
    [[NSColor colorWithCalibratedRed:(46)/255.0f
                               green:(58)/255.0f
                                blue:(75)/255.0f
                               alpha:1.0f]     set];
    
    
    [path fill];
    
    //Left circle
    [[NSColor colorWithCalibratedRed:(255)/255.0f
                               green:(255)/255.0f
                                blue:(255)/255.0f
                               alpha:1.0f]     set];
    
    NSRect leftRect = NSMakeRect(width/4, height/2, 8, 8);
    NSBezierPath* leftCircle = [NSBezierPath bezierPath];
    [leftCircle appendBezierPathWithOvalInRect:leftRect];
    [leftCircle fill];
    
    //Right circle
    [[NSColor colorWithCalibratedRed:(255)/255.0f
                               green:(255)/255.0f
                                blue:(255)/255.0f
                               alpha:1.0f]     set];
    
    NSRect rightRect = NSMakeRect(width/4*3, height/2, 8, 8);
    NSBezierPath* rightCircle = [NSBezierPath bezierPath];
    [rightCircle appendBezierPathWithOvalInRect:rightRect];
    [rightCircle fill];

}

@end
