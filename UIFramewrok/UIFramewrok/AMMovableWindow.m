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
    return NO;
}

- (void)sendEvent:(NSEvent *)theEvent
{
    if([theEvent type] == NSKeyDown)
    {
        if([theEvent keyCode] == 36)
            return;
    }
    
    if([theEvent type] == NSLeftMouseDown)
        [self mouseDown:theEvent];
    else if([theEvent type] == NSLeftMouseDragged)
        [self mouseDragged:theEvent];
    [super sendEvent:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint windowLocaion=[theEvent locationInWindow];
    //TODO:fix a bug only the top bar can be drag ,but not the full background.
    if(windowLocaion.y<740.f)
    {
        return;
    }
    self.initialLocation = [theEvent locationInWindow];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint currentLocation;
    NSPoint newOrigin;
    NSPoint windowLocaion=[theEvent locationInWindow];
    //TODO:fix a bug only the top bar can be drag ,but not the full background.
    if(windowLocaion.y<740.f)
    {
        return;
    }
    
    NSRect  screenFrame = [[NSScreen mainScreen] frame];
    NSRect  windowFrame = [self frame];
    
    currentLocation = [NSEvent mouseLocation];
    newOrigin.x = currentLocation.x - self.initialLocation.x;
    newOrigin.y = currentLocation.y - self.initialLocation.y;
    
    // Don't let window get dragged up under the menu bar
    if( (newOrigin.y+windowFrame.size.height) > (screenFrame.origin.y+screenFrame.size.height) ){
        newOrigin.y=screenFrame.origin.y + (screenFrame.size.height-windowFrame.size.height);
    }
    
    [self setFrameOrigin:newOrigin];
}

@end
