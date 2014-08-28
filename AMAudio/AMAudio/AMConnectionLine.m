//
//  AMConnectionLine.m
//  RouterPanel
//
//  Created by Brad Phillips on 8/21/14.
//  Copyright (c) 2014 Detao. All rights reserved.
//

#import "AMConnectionLine.h"

@implementation AMConnectionLine

@synthesize coords;
@synthesize isHidden;
@synthesize name;

- (id)initWithFrame:(NSRect)frame andCoords:(NSMutableArray *)sentCoords
{
    
    self = [super initWithFrame:frame];
    if (self) {
        //NSLog(@"sent coords are %@",sentCoords);
        CGFloat xCoord1 = [sentCoords[0] floatValue];
        CGFloat yCoord1 = [sentCoords[1] floatValue];
        CGFloat xCoord2 = [sentCoords[2] floatValue];
        CGFloat yCoord2 = [sentCoords[3] floatValue];
        
        // Initialization code here.
        // Create a path object
        path = [[NSBezierPath alloc] init];
        [path setLineWidth:1.0];
        
        NSPoint origin = {xCoord1, yCoord1};
        NSPoint end = {xCoord2, yCoord2};
        
        [path moveToPoint:origin];
        
        //[path lineToPoint:end];
        [path curveToPoint:end controlPoint1:NSMakePoint(self.frame.size.width/2 ,self.frame.size.height/2) controlPoint2:NSMakePoint(self.frame.size.width/2 ,self.frame.size.height/2)];
        
        //[path closePath];
        
        self.isHidden = 0;
    }
    
    if (![super initWithFrame:frame])
        return nil;
    
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
    //NSRect bounds = [self bounds];
    
    // Draw the path in white
    //[[NSColor whiteColor] set];
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    
    switch (self.isHidden) {
        case 1:
            NSLog(@"test");
            CGContextSetRGBStrokeColor(context, 0.0, 1, 0.0, 0);
            break;
        default:
            CGContextSetRGBStrokeColor(context, 0.0, 1, 0.0, 1);
            break;
    }
    [path stroke];
    
}

@end
