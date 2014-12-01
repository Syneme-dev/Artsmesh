//
//  TestView.m
//  AMAudio
//
//  Created by 王为 on 1/12/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "TestView.h"

@implementation TestView

-(void)drawRect:(NSRect)dirtyRect
{
    [[NSColor redColor] set];
    
    [[NSBezierPath bezierPathWithRect:self.bounds] fill];
}

@end
