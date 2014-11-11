//
//  AMGroupPreviewPanelView.m
//  DemoUI
//
//  Created by Brad Phillips on 11/7/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupPreviewPanelView.h"

#define UI_Color_gray [NSColor colorWithCalibratedRed:0.152 green:0.152 blue:0.152 alpha:1]

@implementation AMGroupPreviewPanelView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UI_Color_gray;
        
        NSShadow *dropShadow = [[NSShadow alloc] init];
        [dropShadow setShadowColor:colorFromRGB(0, 0, 0, 0.5)];
        [dropShadow setShadowOffset:NSMakeSize(0, -4.0)];
        [dropShadow setShadowBlurRadius:4.0];
        [self setShadow:dropShadow];
        
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self.backgroundColor set];
    [NSBezierPath fillRect:self.bounds];
}

static NSColor *colorFromRGB(unsigned char r, unsigned char g, unsigned char b, float a)
{
    return [NSColor colorWithCalibratedRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:a];
}

@end
