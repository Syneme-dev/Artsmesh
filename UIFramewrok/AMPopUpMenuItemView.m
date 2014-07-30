//
//  AMPopUpMenuItemView.m
//  UIFramework
//
//  Created by Wei Wang on 7/30/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMPopUpMenuItemView.h"

@implementation AMPopUpMenuItemView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.backgroupColor = [NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.15 alpha:1];
        self.title = @"";
        self.textColor = [NSColor grayColor];
        self.drawBackground = NO;
        self.font = [NSFont fontWithName: @"FoundryMonoline-Bold" size: self.font.pointSize];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    [NSGraphicsContext saveGraphicsState];
    
    //Drawing background
    if (self.drawBackground) {
        NSBezierPath* border = [NSBezierPath bezierPathWithRect:self.bounds];
        [self.backgroupColor set];
        [border fill];
    }
    
    // Drawing title
    NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] init];
    
    if (self.font) {
        textAttributes[NSFontAttributeName] = self.font;
    }
    
    if (self.textColor) {
        textAttributes[NSForegroundColorAttributeName] = self.textColor;
    }
    
    NSSize fontSize = [self.title sizeWithAttributes:textAttributes];
    NSPoint titleLocation = NSMakePoint(0, (self.bounds.size.height - fontSize.height) /2);
    [self.title drawAtPoint:titleLocation withAttributes:textAttributes];
    
    [NSGraphicsContext restoreGraphicsState];
}

@end
