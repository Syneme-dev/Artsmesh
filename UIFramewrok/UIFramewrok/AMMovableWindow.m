//
//  AMMovableWindow.m
//  UIFramewrok
//
//  Created by xujian on 4/2/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMMovableWindow.h"

@implementation AMMovableWindow
- (BOOL) canBecomeKeyWindow
{
    return YES;
}

- (BOOL) acceptsFirstResponder
{
    return YES;
}

- (NSTimeInterval)animationResizeTime:(NSRect)newWindowFrame
{
    return 0.1;
}

- (BOOL)isMovableByWindowBackground {
    return YES;
}


@end
