//
//  AMFlippedView.m
//  DemoUI
//
//  Created by Brad Phillips on 11/14/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMFlippedView.h"

@implementation AMFlippedView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [NSColor blueColor];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
}

- (BOOL)isFlipped
{
    return YES;
}

@end
