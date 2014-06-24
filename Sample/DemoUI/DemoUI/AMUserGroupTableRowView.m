//
//  AMUserGroupTableRowView.m
//  DemoUI
//
//  Created by Wei Wang on 6/24/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserGroupTableRowView.h"

@implementation AMUserGroupTableRowView

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
        [(NSButton *)subview setImage:[NSImage imageNamed:@"chat_command"]];
        [(NSButton *)subview setAlternateImage:[NSImage imageNamed:@"chat_command"]];
    }
}

@end
