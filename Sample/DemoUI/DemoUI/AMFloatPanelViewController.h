//
//  AMFloatPanelViewController.h
//  DemoUI
//
//  Created by Brad Phillips on 11/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMLiveMapView.h"

@interface AMFloatPanelViewController : NSViewController

@property AMLiveMapView *liveMap;
@property BOOL isClosed;

- (IBAction)closePanel:(id)sender;

#define floatPanelNotification @"floatPanelClosed"


@end
