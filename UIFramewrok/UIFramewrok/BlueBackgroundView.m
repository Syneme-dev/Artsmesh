//
//  BlueBackgroundView.m
//  UIFramewrok
//
//  Created by xujian on 3/31/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "BlueBackgroundView.h"

@implementation BlueBackgroundView

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
    [[NSColor colorWithCalibratedRed:(48+12)/255.0f green:(64+11)/255.0f blue:(80+14)/255.0f alpha:1.0f] set];
    NSRectFill([self bounds]);
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

@end
