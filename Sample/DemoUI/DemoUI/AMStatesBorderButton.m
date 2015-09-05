//
//  AMStatesBorderButton.m
//  UIFramework
//
//  Created by Brad Phillips on 9/5/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMStatesBorderButton.h"

@implementation AMStatesBorderButton

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.buttonVC = [[AMStatesBorderButtonViewController alloc] initWithNibName:@"AMStatesBorderButtonViewController" bundle:nil];
        NSView *vcView = [self.buttonVC view];
        
        [self setAutoresizesSubviews:TRUE];
        vcView.autoresizingMask = NSViewWidthSizable |  NSViewHeightSizable;
        
        NSSize newSize = NSMakeSize(self.frame.size.width, self.frame.size.height);
        
        [vcView setFrameSize:newSize];
        
        [self addSubview:vcView];
    }
    
    return self;
}


- (void)drawRect:(NSRect)dirtyRect {
    
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
    
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setButtonTitle:(NSString *)buttonTitle {
    [self.buttonVC.buttonTitleTextField setStringValue:buttonTitle];
    
    [self setNeedsDisplay:true];
}

@end
