//
//  AMFlippedView.m
//  DemoUI
//
//  Created by Brad Phillips on 11/14/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMFlippedView.h"

@implementation AMFlippedView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //self.backgroundColor = [NSColor blueColor];
        self.backgroundColor = nil;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    if ( self.backgroundColor != nil ) {
        [self.backgroundColor setFill];
        NSRectFill(dirtyRect);
    }
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
}

- (void)changeBackgroundColor:(NSColor *)backgroundColor {
    
    self.backgroundColor = backgroundColor;
    
}

- (BOOL)isFlipped
{
    return YES;
}

@end
