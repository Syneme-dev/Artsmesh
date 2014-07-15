//
//  AMTextView.m
//  UIFramework
//
//  Created by xujian on 5/30/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMTextView.h"

@implementation AMTextView

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
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)awakeFromNib
{
    [self setFont: [NSFont fontWithName: @"FoundryMonoline-Bold" size: self.font.pointSize]];
    [self setFocusRingType:NSFocusRingTypeNone];
}

@end
