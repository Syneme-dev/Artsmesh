//
//  AMTabItemView.m
//  DemoUI
//
//  Created by 王 为 on 7/16/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMTabItemView.h"

@implementation AMTabItemView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
//    
//    [[NSColor redColor] set];
//    [NSBezierPath fillRect:self.bounds];
    // Drawing code here.
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}

@end
