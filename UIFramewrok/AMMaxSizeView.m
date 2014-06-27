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
        // Initialization code here.
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

@end
