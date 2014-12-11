//
//  AMOscMsgTableRow.m
//  AMOSCGroups
//
//  Created by wangwei on 10/12/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import "AMOscMsgTableRow.h"

@implementation AMOscMsgTableRow

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
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
