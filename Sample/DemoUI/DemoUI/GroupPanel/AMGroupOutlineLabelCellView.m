//
//  AMGroupOutlineLabelCellView.m
//  DemoUI
//
//  Created by 王 为 on 7/4/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupOutlineLabelCellView.h"

@implementation AMGroupOutlineLabelCellView

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
}

- (void)drawBackgroundInRect:(NSRect)dirtyRect
{
    NSColor* color = [NSColor blueColor];
    [color setFill];
    NSRectFill(dirtyRect);
}



@end
