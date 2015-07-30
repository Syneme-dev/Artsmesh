//
//  AMFakeBox.h
//  UIFramework
//
//  Created by whiskyzed on 7/30/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
//The FakeBox is meant to make the subview looks like a AMBox, which has a blue line upper, and two blue rect at both left bottom
// and right bottom.

@interface AMFakeBox : NSView
@property BOOL drawUpperLine;
@property BOOL drawBottomRects;
@end
