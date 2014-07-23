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
        NSButton* triangleBtn = (NSButton *)subview;
        
        if (self.headImage != nil && self.alterHeadImage != nil) {
            [triangleBtn setImage:self.headImage];
            [triangleBtn setAlternateImage:self.alterHeadImage];
            
            NSRect rect = NSMakeRect(triangleBtn.frame.origin.x,
                                     triangleBtn.frame.origin.y+5,
                                     15,
                                     15);

            [triangleBtn setFrame:rect];
        }
    }
}

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone) {
        NSRect selectionRect = NSInsetRect(self.bounds, 1, 1);
        [[NSColor colorWithCalibratedRed:0.2 green:0.2 blue:0.2 alpha:1] setStroke];
        [[NSColor colorWithCalibratedRed:0.2 green:0.2 blue:0.2 alpha:1] setFill];
        NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRect:selectionRect];
        [selectionPath fill];
        [selectionPath stroke];
    }
}

@end
