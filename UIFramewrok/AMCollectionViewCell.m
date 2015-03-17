//
//  AMCollectionViewCell.m
//  UIFramework
//
//  Created by whiskyzed on 3/9/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMCollectionViewCell.h"

@implementation AMCollectionViewCell
@synthesize selected;

- (void) setSelected:(BOOL)flag
{
    selected = flag;
    [self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)dirtyRect {
   [super drawRect:dirtyRect];
    if (self.selected) {
        NSRect bounds = [self bounds];
        [[NSColor colorWithCalibratedRed:0.176 green:0.23 blue:0.298 alpha:1.0] set];
       // [bgColor ];
//        [[NSColor keyboardFocusIndicatorColor] set];
        [NSBezierPath setDefaultLineWidth:4.0];
        [NSBezierPath strokeRect:bounds];
        
    }
    
    

    /*
    NSRect imageRect = NSMakeRect(5,5,self.frame.size.width -10,self.frame.size.height -10);
    
    NSBezierPath* imageRoundedRectanglePath = [NSBezierPath bezierPathWithRoundedRect:imageRect xRadius: 4 yRadius: 4];
    NSColor* fillColor = nil;
    NSColor* strokeColor = nil;
    
    //默认是未选中的
    if (self.selected) {
        
        fillColor = [NSColor colorWithCalibratedRed:0.851 green:0.851 blue:0.851 alpha:1];
        strokeColor = [NSColor colorWithCalibratedRed:0.408 green:0.592 blue:0.855 alpha: 1];
        
    }else{
        
        fillColor = [NSColor clearColor];
        strokeColor = [NSColor colorWithCalibratedRed: 0.749 green: 0.749 blue: 0.749 alpha: 1];
    }
    
    [fillColor setFill];
    [imageRoundedRectanglePath fill];
    [strokeColor setStroke];
    
    [super drawRect:dirtyRect];
     */
}

- (instancetype) initWithFrame:(NSRect)frameRect{
    if (self = [super initWithFrame:frameRect]) {
//        selected = YES;
    }
    return self;
}

@end
