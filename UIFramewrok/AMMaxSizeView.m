//
//  AMMaxSizeView.m
//  DemoUI
//
//  Created by xujian on 3/5/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMMaxSizeView.h"

@implementation AMMaxSizeView

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
    //Color RBG:333333
    [[NSColor colorWithCalibratedRed:(38)/255.0f green:(38)/255.0f blue:(38)/255.0f alpha:1.0f] set];
    NSRectFill([self bounds]);
	[super drawRect:dirtyRect];
}

@end
