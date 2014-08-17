//
//  AMGroupOutlineView.m
//  DemoUI
//
//  Created by Wei Wang on 8/15/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupOutlineView.h"
#import "AMGroupPanelTableCellController.h"

@implementation AMGroupOutlineView

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

-(void)reloadData
{
    [super reloadData];
	for(int i = 0; i < [self numberOfRows]; i++ ) {
		id item = [self itemAtRow:i];
        
        if ([item isExpanded]) {
            [self expandItem:item];
        }
	}
}

@end
