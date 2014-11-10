//
//  AMVolumeCtlView.m
//  AMAudio
//
//  Created by 王为 on 10/11/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMVolumeCtlView.h"

@implementation AMVolumeCtlView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    NSColor *fillColor= [NSColor colorWithCalibratedRed:(46)/255.0f green:(58)/255.0f blue:(75)/255.0f alpha:1.0f];
    [fillColor set];
    [NSBezierPath fillRect:self.bounds];
    
    [[NSColor grayColor] set];
    [NSBezierPath strokeRect:self.bounds];
}

@end
