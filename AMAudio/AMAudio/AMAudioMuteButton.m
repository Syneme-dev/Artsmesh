//
//  AMAudioMuteButton.m
//  AMAudio
//
//  Created by 王为 on 9/12/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAudioMuteButton.h"
#import "UIFramework/AMButtonHandler.h"

@implementation AMAudioMuteButton
{
    BOOL _onState;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    if (!_onState) {
        [UI_Color_blue set];
    }else{
        [[NSColor redColor] set];
    }
    
    NSRect rect = self.bounds;
    rect = NSInsetRect(rect, 3.0, 3.0);
    
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:rect];
    path.lineWidth = 2.0;
    [path stroke];
}

-(void)viewWillDraw
{
    [AMButtonHandler changeTabTextColor:self toColor:UI_Color_blue];
}

-(void)setButtonOnState:(BOOL)onState
{
    _onState = onState;
    [self setNeedsDisplay];
}



@end
