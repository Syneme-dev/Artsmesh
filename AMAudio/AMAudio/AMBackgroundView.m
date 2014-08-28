//
//  AMBackgroundView.m
//  RouterPanel
//
//  Created by Brad Phillips on 8/21/14.
//  Copyright (c) 2014 Detao. All rights reserved.
//

#import "AMBackgroundView.h"

@implementation AMBackgroundView

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
    
    // Drawing code here.
    
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetRGBFillColor(context, 0.2, 0.2, 0.2, 1);
    CGContextFillRect(context, NSRectToCGRect(dirtyRect));
}

@end
