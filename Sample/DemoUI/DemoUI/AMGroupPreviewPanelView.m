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
        
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self.backgroundColor set];
    [NSBezierPath fillRect:self.bounds];
}

@end
