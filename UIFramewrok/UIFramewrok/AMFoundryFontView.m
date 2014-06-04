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

- (void)awakeFromNib
{
    [self setFont: [NSFont fontWithName: @"FoundryMonoline-Bold" size: self.font.pointSize]];
}


@end
