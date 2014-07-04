//
//  AMUserDetailView.m
//  DemoUI
//
//  Created by 王 为 on 7/4/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserDetailView.h"

@implementation AMUserDetailView

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
    
    NSColor* color = [NSColor colorWithCalibratedRed:0.227f
                                                       green:0.251f
                                                        blue:0.337
                                                       alpha:0];
    [color setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
    // Drawing code here.
}

@end
