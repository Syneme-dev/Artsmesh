//
//  AMFloatPanel.h
//  DemoUI
//
//  Created by Brad Phillips on 11/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMFloatPanel : NSView

@property(nonatomic) NSSize initialSize;
@property(nonatomic) BOOL inFullScreenMode;
@property(nonatomic) NSColor* backgroundColor;
@property(nonatomic, weak) NSViewController *floatPanelViewController;

@end
