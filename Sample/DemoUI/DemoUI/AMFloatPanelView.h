//
//  AMFloatPanel.h
//  DemoUI
//
//  Created by Brad Phillips on 11/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UIFramework/AMBoxItem.h"
#import "AMFloatPanelViewController.h"


@interface AMFloatPanelView : AMBoxItem

@property(nonatomic) NSSize initialSize;
@property(nonatomic) int borderThickness;
@property(nonatomic) BOOL tearedOff;
@property(nonatomic) BOOL inFullScreenMode;
@property(nonatomic) BOOL isDragging;
@property(nonatomic) NSColor* backgroundColor;
@property(nonatomic, weak) AMFloatPanelViewController *floatPanelViewController;

@end
