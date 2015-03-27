//
//  AMCollectionViewCell.m
//  UIFramework
//
//  Created by whiskyzed on 3/9/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMCollectionViewCell.h"
//#import "Artsmesh/AMTimerTabVC.h"

@implementation AMCollectionViewCell
@synthesize selected;

- (void) setSelected:(BOOL)flag
{
    selected = flag;
    [self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)dirtyRect {
   [super drawRect:dirtyRect];
    if (self.selected) {
        NSRect bounds = [self bounds];
        [[NSColor colorWithCalibratedRed:0.176 green:0.23 blue:0.298 alpha:1.0] set];
        [NSBezierPath setDefaultLineWidth:4.0];
        [NSBezierPath strokeRect:bounds];
    }
}

- (instancetype) initWithFrame:(NSRect)frameRect{
    if (self = [super initWithFrame:frameRect]) {
//        selected = YES;
    }
    return self;
}

@end
