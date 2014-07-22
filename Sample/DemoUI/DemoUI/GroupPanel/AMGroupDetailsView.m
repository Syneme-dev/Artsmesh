//
//  AMGroupDetailsView.m
//  DemoUI
//
//  Created by 王 为 on 7/7/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupDetailsView.h"
#import <UIFramework/AMButtonHandler.h>

@implementation AMGroupDetailsView

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
    [AMButtonHandler changeTabTextColor:self.joinGroupBtn toColor:UI_Color_b7b7b7];
    [AMButtonHandler changeTabTextColor:self.cancelBtn toColor:UI_Color_b7b7b7];
    [self.layer setBackgroundColor:[[NSColor colorWithCalibratedRed:0.14
                                                              green:0.14
                                                               blue:0.14
                                                              alpha:0.95] CGColor]];
    
    NSRect contentR = self.bounds;
    
    [NSGraphicsContext saveGraphicsState];
    
    [[NSColor grayColor] set];
    NSBezierPath *btnLine = [NSBezierPath bezierPath];
    [btnLine moveToPoint:NSMakePoint(contentR.origin.x, contentR.origin.y + 36)];
    [btnLine lineToPoint:NSMakePoint(contentR.origin.x + contentR.size.width, contentR.origin.y + 36)];
    [btnLine moveToPoint:NSMakePoint(contentR.origin.x + contentR.size.width / 2, contentR.origin.y + 36)];
    [btnLine lineToPoint:NSMakePoint(contentR.origin.x + contentR.size.width / 2, contentR.origin.y)];
    [btnLine stroke];
    [NSGraphicsContext restoreGraphicsState];
    
//    NSRect firstBtnRect = NSMakeRect(contentR.origin.x,
//                                     contentR.origin.y,
//                                     contentR.size.width / 2 -1,
//                                     35);
//    
//    NSRect lastBtnRect = NSMakeRect(contentR.origin.x + contentR.size.width / 2 + 1,
//                                    contentR.origin.y,
//                                    contentR.size.width / 2 - 1,
//                                    35);
//    
//    [self.joinGroupBtn setFrame:firstBtnRect];
//    [self.cancelBtn setFrame:lastBtnRect];
}

-(BOOL)acceptsFirstResponder
{
    return  YES;
}

-(void)mouseDown:(NSEvent *)theEvent
{
    return;
}


@end
