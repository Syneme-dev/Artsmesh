//
//  AMConnectionLine.h
//  RouterPanel
//
//  Created by Brad Phillips on 8/21/14.
//  Copyright (c) 2014 Detao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMConnectionLine : NSView
{
    NSPoint *startPoint;
    NSPoint *endPoint;
    NSBezierPath *path;
}

@property (nonatomic, strong) NSMutableArray *coords;
@property (nonatomic, assign) int isHidden;
@property (nonatomic, strong) NSString *name;

- (id)initWithFrame:(NSRect)frame andCoords:(NSMutableArray *)sentCoords;
//- (void)setCoords:(CGFloat)x1;

@end
