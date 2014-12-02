//
//  AMJackCPULoderView.m
//  DemoUI
//
//  Created by wangwei on 2/12/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMJackCPULoderView.h"
#import <math.h>

@implementation AMJackCPULoderView
{
    float _cpuUsage;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    float usageSqrt = sqrtf(_cpuUsage / 100);
    
    NSRect rect = self.bounds;
    rect.size.width = usageSqrt *rect.size.width;
    
    [[NSColor grayColor] set];
    [[NSBezierPath bezierPathWithRect:rect] fill];
}

-(void)setCpuUsage:(float)value
{
    _cpuUsage = value;
    [self setNeedsDisplay:YES];
}

@end
