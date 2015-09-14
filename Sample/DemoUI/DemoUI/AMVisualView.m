//
//  AMVisualView.m
//  Artsmesh
//
//  Created by whiskyzed on 8/4/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMVisualView.h"
static const int Up = 5;
static const int Bottom = 0;

static NSInteger halfBarWidth = 4; //Real white bar widht is halfBarWidth*2+1;plus one for the
//right symetric when the auxiliary line is in the middle.



@implementation AMVisualView
{
    NSMutableArray* verticalAuxiliaryXPos;
    NSInteger       verticalAuxiliaryCount;
}


- (void) drawBoundaryWithWidth : (CGFloat) width
               withHeight      : (CGFloat) height
{
    // Draw the upper blue line.
    NSRect lineRect = NSMakeRect(0,  height - Up, width, 2);
    NSBezierPath* path = [NSBezierPath bezierPathWithRect:lineRect];
    [[NSColor colorWithCalibratedRed:(42)/255.0f
                               green:(48)/255.0f
                                blue:(57)/255.0f
                               alpha:1.0f]     set];
    [path fill];
    
    // Draw the down blue line.
    NSRect bottomLineRect = NSMakeRect(0,  Bottom, width, 2);
    NSBezierPath* bottomPath = [NSBezierPath bezierPathWithRect:bottomLineRect];
    [bottomPath fill];
    
    // Draw the middle blue line.
    CGFloat midHPosition = (height - Up + Bottom) / 2;
    NSRect middleHRect = NSMakeRect(0,  midHPosition, width, 2);
    NSBezierPath* middleHPath = [NSBezierPath bezierPathWithRect:middleHRect];

    [middleHPath fill];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    CGFloat width  = [self bounds].size.width;
    CGFloat height = [self bounds].size.height;

    [self drawBoundaryWithWidth:width withHeight:height];
     CGFloat midHPosition = (height + Up - Bottom) / 2;
    
    [self drawHorizontalAuxiliary:width YStart:0 YEnd:midHPosition withCount:2];
    [self drawHorizontalAuxiliary:width YStart:midHPosition YEnd:height withCount:2];
 
    [self drawVerticalAuxiliary:height XStart:0 XEnd:width-Up withCount:4];
    
    [self drawWhiteBarsCount:5];
}


- (void) drawHorizontalAuxiliary : (CGFloat) width
                YStart           : (CGFloat) YStart
                YEnd             : (CGFloat) YEnd
                withCount        : (NSInteger) count
{
    CGFloat delta = (YEnd - YStart)/(count + 1);
    
    for (int i = 0; i < count; i++) {
        CGFloat height = YStart + delta * (i + 1);
        NSBezierPath *auxiliaryLine = [NSBezierPath bezierPath];
        NSPoint startPoint = NSMakePoint(0,    height);
        NSPoint endPoint   = NSMakePoint(width, height);
        [auxiliaryLine moveToPoint:startPoint];
        [auxiliaryLine lineToPoint:endPoint];
        auxiliaryLine.lineWidth = 1.0;
        
        [[NSColor colorWithCalibratedRed:(40)/255.0f
                                   green:(43)/255.0f
                                    blue:(47)/255.0f
                                   alpha:1.0f]     setStroke];
        [auxiliaryLine stroke];
    }
}

- (void) drawVerticalAuxiliary   : (CGFloat) height
                XStart           : (CGFloat) XStart
                XEnd             : (CGFloat) XEnd
                withCount        : (NSInteger) count
{
    CGFloat delta = (XEnd - XStart)/(count + 1);
    
    if (verticalAuxiliaryXPos == nil ||
        verticalAuxiliaryCount != count) {
        verticalAuxiliaryXPos = [[NSMutableArray alloc] init];
        verticalAuxiliaryCount = count;
        
        for (int i = 0; i < count; i++) {
            CGFloat XPos = XStart + delta * (i + 1);
            NSNumber* number = [[NSNumber alloc] initWithDouble:XPos];
            [verticalAuxiliaryXPos insertObject:number atIndex:i];
        }
    }

    for (int i = 0; i < count; i++) {
 //       CGFloat width = YStart + delta * (i + 1);
       
        NSNumber* curNumber= [verticalAuxiliaryXPos objectAtIndex:i];
        CGFloat curXPos  = [curNumber doubleValue];
        NSBezierPath *auxiliaryLine = [NSBezierPath bezierPath];
        
        NSPoint startPoint = NSMakePoint(curXPos, Bottom+2);
        NSPoint endPoint   = NSMakePoint(curXPos, height-Up);
        [auxiliaryLine moveToPoint:startPoint];
        [auxiliaryLine lineToPoint:endPoint];
        auxiliaryLine.lineWidth = 1.0;
        
        [[NSColor colorWithCalibratedRed:(40)/255.0f
                                   green:(43)/255.0f
                                    blue:(47)/255.0f
                                   alpha:1.0f]     setStroke];
        [auxiliaryLine stroke];
    }
}


-(NSPoint) auxiliaryPointIndex : (NSInteger) index
                withCount      : (NSInteger) count
{
    if (index == 0) {
        return NSMakePoint(halfBarWidth, 0);
    }
    
    return NSMakePoint([self bounds].size.width / count * index, 0);
}

- (void) drawWhiteBarsCount : (NSInteger) count
{
    CGFloat width = 2*halfBarWidth + 1;
    CGFloat height = [self bounds].size.height;
    
    [[NSColor colorWithCalibratedRed:(168)/255.0f
                               green:(168)/255.0f
                                blue:(168)/255.0f
                               alpha:1.0f]     set];
    //Draw first bar
    
    
    NSRect firstBarRect = NSMakeRect(0, 0, width, height*0.1);
    [[NSBezierPath bezierPathWithRect:firstBarRect] fill];
    
    
    //Draw other bars
    for (int i = 0; i < count - 1; i++) {
        [self drawWhiteBarIndex:i withCount:count - 1];
    }
}

- (void) drawWhiteBarIndex : (NSInteger)index
             withCount     : (NSInteger) count
{
    
    NSNumber* curNum  = [verticalAuxiliaryXPos objectAtIndex:index];
    CGFloat   midXPos = [curNum doubleValue];
    CGFloat   ratio   = [self ratioValue:index];
    
    CGFloat xPos = midXPos - halfBarWidth;
    CGFloat yPos = 0;
    CGFloat width = 2*halfBarWidth + 1;
    CGFloat height = ratio* [self bounds].size.height;
    
    
    NSRect barRect = NSMakeRect(xPos, yPos, width, height);
    [[NSBezierPath bezierPathWithRect:barRect] fill];
}

- (CGFloat) ratioValue : (NSInteger) index
{
    return (index+2)/10.0;
}

@end
