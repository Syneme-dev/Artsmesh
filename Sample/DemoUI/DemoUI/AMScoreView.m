//
//  AMScoreView.m
//  Artsmesh
//
//  Created by whiskyzed on 4/8/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMScoreView.h"

@implementation AMScoreView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    NSRect lineRect = NSMakeRect(0, 60, self.bounds.size.width, 1);
    NSBezierPath* path = [NSBezierPath bezierPathWithRect:lineRect];
    [[NSColor colorWithCalibratedRed:(46)/255.0f
                               green:(58)/255.0f
                                blue:(75)/255.0f
                               alpha:1.0f]
                                            set];
    
    [path fill];
}

- (BOOL) acceptsFirstResponder
{
    return YES;
}

@end
