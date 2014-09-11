//
//  NSBezierPath+QuartzUtilities.m
//  AMAudio
//
//  Created by lattesir on 9/9/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "NSBezierPath+QuartzUtilities.h"

@implementation NSBezierPath (QuartzUtilities)

- (CGPathRef)quartzPath:(BOOL)needClose
{
    CGPathRef immutablePath = NULL;
    
    if (self.elementCount > 0)
    {
        CGMutablePathRef path = CGPathCreateMutable();
        NSPoint points[3];
        BOOL didClosePath = YES;
        
        for (int i = 0; i < self.elementCount; i++) {
            switch ([self elementAtIndex:i associatedPoints:points]) {
            case NSMoveToBezierPathElement:
                CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
                break;
                    
            case NSLineToBezierPathElement:
                CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                didClosePath = NO;
                break;
                    
            case NSCurveToBezierPathElement:
                CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
                                      points[1].x, points[1].y,
                                      points[2].x, points[2].y);
                didClosePath = NO;
                break;
                    
            case NSClosePathBezierPathElement:
                CGPathCloseSubpath(path);
                didClosePath = YES;
                break;
            }
        }

        if (needClose && !didClosePath)
            CGPathCloseSubpath(path);
        
        immutablePath = CGPathCreateCopy(path);
        CGPathRelease(path);
    }
    
    return immutablePath;
}

@end
