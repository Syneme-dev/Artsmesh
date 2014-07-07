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
    [AMButtonHandler changeTabTextColor:self.joinGroupBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.cancelBtn toColor:UI_Color_blue];
    [self.layer setBackgroundColor:[[NSColor colorWithCalibratedRed:0.14
                                                              green:0.14
                                                               blue:0.14
                                                              alpha:0.95] CGColor]];
    
}

@end
