//
//  AMOutlineView.m
//  DemoUI
//
//  Created by 王为 on 21/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMOutlineView.h"
#import "AMOutlineItem.h"

@implementation AMOutlineView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


-(void)reloadData
{
    [super reloadData];
    for(int i = 0; i < [self numberOfRows]; i++ ) {
        id item = [self itemAtRow:i];
        
        if ([item shouldExpanded]) {
            [self expandItem:item];
        }
    }
}

@end
