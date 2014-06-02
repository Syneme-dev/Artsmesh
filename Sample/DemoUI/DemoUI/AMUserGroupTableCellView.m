//
//  AMUserGroupTableCellView.m
//  DemoUI
//
//  Created by Wei Wang on 4/25/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserGroupTableCellView.h"
#import "AMUserGroupNode.h"

@implementation AMUserGroupTableCellView

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

- (void)mouseEntered:(NSEvent *)theEvent
{
    for (NSView* view in self.subviews )
    {
        if ([view isKindOfClass:[NSButton class]])
        {
            if([self.objectValue isKindOfClass:[AMUserGroupNode class]])
            {
                AMUserGroupNode* node = self.objectValue;
                if (node.isLeaf == NO)
                {
                     [view setHidden:NO];
                }
            }
        }
    }
    
     //NSLog(@"Mouse Entered!");
}

- (void)mouseExited:(NSEvent *)theEvent
{
    
    for (NSView* view in self.subviews )
    {
        if ([view isKindOfClass:[NSButton class]])
        {
            [view setHidden:YES];
        }
    }
    
    //NSLog(@"Mouse Exited!");
    
}

-(void)viewDidMoveToSuperview
{
    NSRect rect = [self frame];
    NSTrackingArea* trackArea = [[NSTrackingArea alloc]
                                 initWithRect:rect
                                 options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved |NSTrackingActiveInKeyWindow )
                                 owner:self
                                 userInfo:nil];
    
    [self addTrackingArea:trackArea];
}

@end
