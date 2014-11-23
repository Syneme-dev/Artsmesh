//
//  AMGroupPreviewPanelView.h
//  DemoUI
//
//  Created by Brad Phillips on 11/7/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMGroupPreviewPanelController.h"
#import "AMCoreData/AMCoreData.h"

@interface AMGroupPreviewPanelView : NSView

@property(nonatomic) NSColor* backgroundColor;
@property(nonatomic, weak) AMGroupPreviewPanelController *groupPreviewPanelController;
@property AMLiveGroup *group;

-(void)setDescription:(AMLiveGroup *)theGroup;

@end
