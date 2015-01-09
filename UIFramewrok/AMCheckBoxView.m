//
//  AMCheckBoxView.m
//  CheckBoxTest
//
//  Created by Wei Wang on 7/14/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMCheckBoxView.h"

@interface AMCheckBoxView()

@end

@implementation AMCheckBoxView
{
    BOOL _checked;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.backgroupColor = [NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.15 alpha:1];
        self.btnBackGroundColor = [NSColor colorWithCalibratedRed:0.10 green:0.10  blue:0.10  alpha:1];
        self.btnColor = [NSColor colorWithCalibratedRed:(60.0/255.0) green:(75.0/255.0) blue:(94.0/255.0) alpha:1];
        self.title = @"";
        self.textColor = [NSColor grayColor];
        self.readOnly = NO;
        self.drawBackground = NO;
        self.font = [NSFont fontWithName: @"FoundryMonoline-Bold" size: 13.0f];
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
    
    //Drawing check box
    CGFloat btnFrameWidth = fontSize.height *1.2;
    CGFloat btnFrameGap = (self.bounds.size.height - btnFrameWidth) / 2;
    NSRect btnFrame = NSMakeRect(self.bounds.size.width - btnFrameGap - btnFrameWidth,
                                 self.bounds.origin.y + btnFrameGap,
                                 btnFrameWidth,
                                 btnFrameWidth);
    
    NSBezierPath* btnFramePath = [NSBezierPath bezierPathWithRect:btnFrame];
    [self.btnBackGroundColor set];
    [btnFramePath fill];
    
    if (self.checked) {
        
        NSRect btnRect = CGRectInset(btnFrame, btnFrameWidth/4, btnFrameWidth/4);
        NSBezierPath* btnPath = [NSBezierPath bezierPathWithRect:btnRect];
        [self.btnColor set];
        [btnPath fill];
    }
   
    [NSGraphicsContext restoreGraphicsState];
}


-(void)mouseDown:(NSEvent *)theEvent
{
    if (self.readOnly || !self.enabled) {
        return;
    }
    self.checked = !self.checked;
    [self setNeedsDisplay];
    
    if (self.delegate) {
        [self.delegate onChecked:self];
    }
}


-(void)setChecked:(BOOL)checked
{
    _checked = checked;
    [self setNeedsDisplay];
}

-(BOOL)checked
{
    return _checked;
}

@end
