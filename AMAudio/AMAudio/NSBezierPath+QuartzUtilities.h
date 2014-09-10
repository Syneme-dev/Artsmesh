//
//  NSBezierPath+QuartzUtilities.h
//  AMAudio
//
//  Created by lattesir on 9/9/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSBezierPath (QuartzUtilities)

- (CGPathRef)quartzPath:(BOOL)needClose;

@end
