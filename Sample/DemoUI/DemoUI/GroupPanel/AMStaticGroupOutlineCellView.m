//
//  AMStaticGroupOutlineCellView.m
//  DemoUI
//
//  Created by Wei Wang on 7/11/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMStaticGroupOutlineCellView.h"

@implementation AMStaticGroupOutlineCellView

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

-(void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    if ([self.delegate respondsToSelector:@selector(viewFrameChanged:)]) {
        [self.delegate viewFrameChanged:nil];
    }
}

@end
