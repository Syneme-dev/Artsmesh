//
//  AMMaxSizeView.m
//  DemoUI
//
//  Created by xujian on 3/5/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMMaxSizeView.h"

#define UI_Color_gray [NSColor colorWithCalibratedRed:0.149 green:0.149 blue:0.149 alpha:1]


@implementation AMMaxSizeView
{
    NSRect _oldWindowFrame;
}


- (NSColor *) colorFromHexRGB:(NSString *) inColorString
{
	NSColor *result = nil;
	unsigned int colorCode = 0;
	unsigned char redByte, greenByte, blueByte;
	
	if (nil != inColorString)
	{
		NSScanner *scanner = [NSScanner scannerWithString:inColorString];
		(void) [scanner scanHexInt:&colorCode];	// ignore error
	}
	redByte		= (unsigned char) (colorCode >> 16);
	greenByte	= (unsigned char) (colorCode >> 8);
	blueByte	= (unsigned char) (colorCode);	// masks off high bits
	result = [NSColor
              colorWithCalibratedRed:		(float)redByte	/ 0xff
              green:	(float)greenByte/ 0xff
              blue:	(float)blueByte	/ 0xff
              alpha:1.0];
	return result;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _oldWindowFrame = NSZeroRect;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    //Color RBG:333333
    

    [UI_Color_gray set];
    NSRectFill([self bounds]);
	[super drawRect:dirtyRect];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if ([theEvent clickCount] == 2) {
        NSPoint location = [theEvent locationInWindow];
        location = [self convertPoint:location fromView:nil];
        CGFloat height = self.bounds.size.height;
        if (location.y > height - 60) {
            NSWindow *window = self.window;
            if (NSEqualRects(_oldWindowFrame, NSZeroRect)) {
                _oldWindowFrame = window.frame;
                CGFloat w, h, x, y;
                w = _oldWindowFrame.size.width;
                h = 60;
                x = _oldWindowFrame.origin.x;
                y = _oldWindowFrame.origin.y + _oldWindowFrame.size.height - h;
                [window.animator setFrame:NSMakeRect(x, y, w, h) display:NO];
            } else {
                [window.animator setFrame:_oldWindowFrame display:YES];
                _oldWindowFrame = NSZeroRect;
            }
        }
    }
}



@end
