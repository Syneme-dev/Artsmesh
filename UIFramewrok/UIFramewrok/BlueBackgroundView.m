//
//  BlueBackgroundView.m
//  UIFramewrok
//
//  Created by xujian on 3/31/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "BlueBackgroundView.h"

@implementation BlueBackgroundView


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

/*
- (void)mouseDown:(NSEvent *)theEvent
{
    [self.superview mouseDown:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    [self.superview mouseDragged:theEvent];
}
 */
-(void)awakeFromNib{
    //if([[[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundColor"] isEqualToString:@"White"])
    //{
        self.color=[NSColor colorWithCalibratedRed:0.177 green:0.227 blue:0.307 alpha:1];
    //}
    //else
    //{
    //self.color=[NSColor colorWithCalibratedRed:(46)/255.0f green:(58)/255.0f blue:(75)/255.0f alpha:1.0f];
    //    self.color=[NSColor lightGrayColor];
   // }
    
}


- (void)drawRect:(NSRect)dirtyRect
{
   
    [self.color set];
    NSRectFill([self bounds]);
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

@end
