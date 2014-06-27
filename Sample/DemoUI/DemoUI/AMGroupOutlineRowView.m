//
//  AMGroupOutlineRowView.m
//  AMGroupOutlineTest
//
//  Created by 王 为 on 6/27/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import "AMGroupOutlineRowView.h"

@implementation AMGroupOutlineRowView

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

-(void)didAddSubview:(NSView *)subview
{
    // As noted in the comments, don't forget to call super:
    [super didAddSubview:subview];
    
    if ( [subview isKindOfClass:[NSButton class]] ) {
        // This is (presumably) the button holding the
        // outline triangle button.
        // We set our own images here.
        NSImage* image =  [self.delegate headImageForRowView:self];
        NSImage* alterImage = [self.delegate alterHeadImageForRowView:self];
        if (image != nil && alterImage != nil) {
            [(NSButton *)subview setImage:image];
            [(NSButton *)subview setAlternateImage:alterImage];
        }
    }
}

@end
