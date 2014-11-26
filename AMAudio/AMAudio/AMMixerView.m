//
//  AMMixerView.m
//  AMCollectionViewTest
//
//  Created by 王为 on 26/11/14.
//  Copyright (c) 2014 wangwei. All rights reserved.
//

#import "AMMixerView.h"

@implementation AMMixerView
{
    NSColor* _backgroundColor;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    if (_backgroundColor) {
        [_backgroundColor set];
        [[NSBezierPath bezierPathWithRect:self.bounds] fill];
    }
    
}

-(void)setBackgroundColor:(NSColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    [self setNeedsDisplay:YES];
}

@end
