//
//  AMUserGroupOutlineView.m
//  DemoUI
//
//  Created by Wei Wang on 4/25/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserGroupOutlineView.h"

@implementation AMUserGroupOutlineView

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

-(void)expandAll
{
    [self expandItem:nil expandChildren:YES];
}

-(void)didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
    [self performSelectorOnMainThread:@selector(expandAll) withObject:nil waitUntilDone:NO];
}

-(void)didRemoveRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
   [self performSelectorOnMainThread:@selector(expandAll) withObject:nil waitUntilDone:NO];
}



@end
