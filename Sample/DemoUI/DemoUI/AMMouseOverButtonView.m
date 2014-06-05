//
//  AMMouseOverButtonView.m
//  DemoUI
//
//  Created by xujian on 6/4/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMMouseOverButtonView.h"
#import <UIFramework/AMUIConst.h>

@implementation AMMouseOverButtonView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)mouseEntered:(NSEvent *)theEvent{
    
    [[self cell] setBackgroundColor:UI_Color_3c4b5d];
}
- (void)mouseExited:(NSEvent *)theEvent{
    
    [[self cell] setBackgroundColor:UI_Color_b7b7b7];
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    
    NSRect fullBounds = [self bounds];
    fullBounds.size.height += 8;
    fullBounds.origin.y-=4;
    [[NSBezierPath bezierPathWithRect:fullBounds] setClip];
    
    // Then do your drawing, for example...
    [UI_Color_b7b7b7 set];
    NSRectFill( fullBounds );
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
