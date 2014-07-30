//
//  AMPopUpButton.m
//  UIFramework
//
//  Created by Wei Wang on 7/30/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMPopUpButton.h"

@implementation AMPopUpButton

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.backgroupColor = [NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.15 alpha:1];
        self.drawBackground = YES;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
    [NSGraphicsContext saveGraphicsState];
    
    if (self.drawBackground) {
        NSBezierPath* border = [NSBezierPath bezierPathWithRect:self.bounds];
        [self.backgroupColor set];
        [border fill];
    }
    
    [NSGraphicsContext restoreGraphicsState];
}

@end
