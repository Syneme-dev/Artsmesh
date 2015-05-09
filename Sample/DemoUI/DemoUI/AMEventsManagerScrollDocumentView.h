//
//  AMEventsManagerScrollDocumentView.h
//  Artsmesh
//
//  Created by Brad Phillips on 5/8/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMEventsManagerRowViewController.h"
#import "GTLYouTube.h"

@interface AMEventsManagerScrollDocumentView : NSView

@property (strong) NSMutableDictionary *eventsRows;

- (void)addRow: (GTLYouTubeLiveBroadcast *)theLiveEvent;
- (void)removeAllRows;

@end
