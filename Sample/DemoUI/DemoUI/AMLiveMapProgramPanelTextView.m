//
//  AMLiveMapProgramPanelTextView.m
//  DemoUI
//
//  Created by Brad Phillips on 11/10/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMLiveMapProgramPanelTextView.h"

@implementation AMLiveMapProgramPanelTextView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.drawsBackground = NO;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (NSSize) intrinsicContentSize {
    NSTextContainer* textContainer = [self textContainer];
    NSLayoutManager* layoutManager = [self layoutManager];
    [layoutManager ensureLayoutForTextContainer: textContainer];
    return [layoutManager usedRectForTextContainer: textContainer].size;
}

- (void) didChangeText {
    [super didChangeText];
    [self invalidateIntrinsicContentSize];
}

@end
