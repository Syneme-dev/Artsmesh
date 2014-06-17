//
//  AMUserGroupTableCellView.m
//  DemoUI
//
//  Created by Wei Wang on 4/25/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserGroupTableCellView.h"
#import "AMUserGroupNode.h"
#import "AMMesher/AMAppObjects.h"


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
    
    if ([self.objectValue isKindOfClass:[AMUser class]]) {
        AMUser *user = (AMUser *)self.objectValue;
        if (user.isOnline)
            [[NSColor greenColor] set];
        else
            [[NSColor lightGrayColor] set];
        NSRectFill(NSMakeRect(2, 5, 5, self.bounds.size.height - 8));
    }
}


@end
