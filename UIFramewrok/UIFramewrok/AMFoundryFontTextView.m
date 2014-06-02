//
//  AMFoundryFontTextView.m
//  UIFramework
//
//  Created by Wei Wang on 6/2/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMFoundryFontTextView.h"

@implementation AMFoundryFontTextView

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
}

@end
