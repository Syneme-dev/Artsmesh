//
//  AMFoundryFontView.m
//  UIFramewrok
//
//  Created by xujian on 4/27/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMFoundryFontView.h"

@implementation AMFoundryFontView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setFont: [NSFont fontWithName: @"FoundryMonoline-Bold" size: self.font.pointSize]];
        [self setFocusRingType:NSFocusRingTypeNone];
        // Initialization code here.
    }
    return self;
}

-(void)setFontSize:(CGFloat)size
{
    [self setFont: [NSFont fontWithName: @"FoundryMonoline-Bold" size:size]];
}

- (void)drawFocusRingMask {
    NSRectFill([self bounds]);
}

- (NSRect)focusRingMaskBounds {
    return [self bounds];
}

-(void)drawRect:(NSRect)rect
{
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
    [super drawRect:rect];
}


- (void)awakeFromNib
{
    [self setFont: [NSFont fontWithName: @"FoundryMonoline-Bold" size: self.font.pointSize]];
    [self setFocusRingType:NSFocusRingTypeNone];
}


@end
