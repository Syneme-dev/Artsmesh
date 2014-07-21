//
//  AMPanelView.h
//  UIFramework
//
//  Created by lattesir on 5/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMBoxItem.h"

@interface AMPanelView : AMBoxItem

@property(nonatomic) NSSize initialSize;
@property(nonatomic) BOOL tearedOff;
@property(nonatomic) BOOL inFullScreenMode;
@property(nonatomic) NSColor* backgroundColor;
@property(nonatomic, weak) NSViewController *panelViewController;

@end
