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
        AMStatesBorderButtonViewController *vc = [[AMStatesBorderButtonViewController alloc] initWithNibName:@"AMStatesBorderButtonViewController" bundle:nil];

        [self addSubview:[vc view]];
    }
    
    return self;
}


- (void)drawRect:(NSRect)dirtyRect {
    
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
    
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
