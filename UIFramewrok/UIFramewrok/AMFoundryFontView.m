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
        
        
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self setFont: [NSFont fontWithName: @"FoundryMonoline-Bold" size: self.font.pointSize]];
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
