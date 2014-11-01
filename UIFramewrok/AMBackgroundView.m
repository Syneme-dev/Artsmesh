//
//  AMBackgroundView.m
//  UIFramework
//
//  Created by lattesir on 10/29/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMBackgroundView.h"

@implementation AMBackgroundView

- (void)drawRect:(NSRect)dirtyRect {
   NSColor *backgroundColor = [NSColor colorWithCalibratedRed:0.15
                                                         green:0.15
                                                          blue:0.15
                                                         alpha:1.0];
    //NSColor* backgroundColor = [NSColor whiteColor];
    [backgroundColor set];
    NSRectFill(self.bounds);
}

@end
