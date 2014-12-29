//
//  AMOSCView.m
//  AMOSCGroups
//
//  Created by wangwei on 29/12/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import "AMOSCView.h"

@implementation AMOSCView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSRect rect = NSMakeRect(0, self.bounds.size.height - 120, self.bounds.size.width, 1);
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
    [[NSColor colorWithCalibratedRed:(46)/255.0f green:(58)/255.0f blue:(75)/255.0f alpha:1.0f] set];
    [path fill];
}

@end
