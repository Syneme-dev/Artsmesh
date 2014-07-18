//
//  AMBorderView.m
//  DemoUI
//
//  Created by lattesir on 7/17/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMBorderView.h"



@implementation AMBorderView

- (id)initWithView:(NSView *)aView
{
    if (!aView)
        return nil;
    
    self = [super init];
    if (self) {
        NSRect rect = NSZeroRect;
        rect.size = aView.frame.size;
        rect.size.width += BORDER_THICKNESS * 2;
        rect.size.height += BORDER_THICKNESS * 2;
        [self setFrame:rect];
        [aView setFrameOrigin:NSMakePoint(BORDER_THICKNESS, BORDER_THICKNESS)];
        [self addSubview:aView];
        
        [aView setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSDictionary *views = NSDictionaryOfVariableBindings(aView);
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[aView]-20-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[aView]-20-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
    }
    return self;
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
  //  [[NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.15 alpha:1.0] set];
  //  NSRectFill(self.bounds);
    [[NSColor clearColor] set];
    NSRectFill(self.bounds);
    [[NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.15 alpha:1.0] set];
    NSBezierPath *roundedRect = [NSBezierPath bezierPathWithRoundedRect:self.bounds
                                                                xRadius:10
                                                                yRadius:10];
    [roundedRect fill];
}

@end
