//
//  AMPanelView.h
//  UIFramework
//
//  Created by lattesir on 5/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMBoxItem.h"

@interface AMPanelView : AMBoxItem

@property(nonatomic) NSColor* backgroundColor;
@property(nonatomic, weak) NSViewController *panelViewController;

- (IBAction)testClick:(id)sender;

@end
