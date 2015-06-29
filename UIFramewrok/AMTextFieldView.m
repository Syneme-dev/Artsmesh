//
//  AMTextFieldView.m
//  DemoUI
//
//  Created by Wei Wang on 5/7/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMTextFieldView.h"

@implementation AMTextFieldView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

//-(void)oldDrawRectBackup:(NSRect)dirtyRect{

-(void)oldDrawRectBackup:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    NSPoint origin = { 0.0,0.0 };
    NSRect rect;
    rect.origin = origin;
    rect.size.width  = [self bounds].size.width;
    rect.size.height = [self bounds].size.height;
    
    NSBezierPath * path;
    path = [NSBezierPath bezierPathWithRect:rect];
    [path setLineWidth:2];
    // [[NSColor colorWithCalibratedWhite:1.0 alpha:0.394] set];
    [[NSColor colorWithCalibratedWhite:1.0 alpha:0.1] set];
    [path fill];
    // [[NSColor redColor] set];
    [path stroke];
    
    if (([[self window] firstResponder] == [self currentEditor]) && [NSApp isActive])
    {
        [NSGraphicsContext saveGraphicsState];
        // NSSetFocusRingStyle(NSFocusRingTypeNone);
        [path fill];
        [NSGraphicsContext restoreGraphicsState];
    }
    else
    {
        [[self attributedStringValue] drawInRect:rect];
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    // Drawing code here.
    NSPoint origin = { 0.0,0.0 };
    NSRect rect;
    rect.origin = origin;
    rect.size.width  = [self bounds].size.width;
    rect.size.height = [self bounds].size.height;
    
    NSBezierPath * path;
    path = [NSBezierPath bezierPathWithRect:rect];
    [path setLineWidth:2];
    // [[NSColor colorWithCalibratedWhite:1.0 alpha:0.394] set];
    [[NSColor colorWithCalibratedWhite:1.0 alpha:0.1] set];
    [path fill];
    // [[NSColor redColor] set];
    [path stroke];
    NSResponder* fr = [[self window] firstResponder];
    if ([fr isKindOfClass:[NSView class]] && [(NSView*)fr isDescendantOf:self])
    {
        [[NSColor whiteColor] set];//Note:Border color
        [NSGraphicsContext saveGraphicsState];
        NSColor *fillColor= [NSColor colorWithCalibratedRed:(46)/255.0f green:(58)/255.0f blue:(75)/255.0f alpha:1.0f] ;//Note:fill color
        [[NSColor grayColor] set];
        NSBezierPath *path=[NSBezierPath bezierPathWithRect:NSInsetRect([self bounds],1,1)] ;
        [path setLineWidth:1.0f];
        [path stroke];
        [fillColor set];
        [path fill];
        [NSGraphicsContext restoreGraphicsState];
    }
}

@end
