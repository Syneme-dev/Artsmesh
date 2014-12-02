//
//  AMBigBlueButton.m
//  UIFramework
//
//  Created by wangwei on 2/12/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMBigBlueButton.h"
#import "AMButtonHandler.h"

@implementation AMBigBlueButton

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    [UI_Color_blue set];
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


@end
