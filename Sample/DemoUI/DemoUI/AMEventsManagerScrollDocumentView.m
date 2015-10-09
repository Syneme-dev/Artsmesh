//
//  AMEventsManagerScrollDocumentView.m
//  Artsmesh
//
//  Created by Brad Phillips on 5/8/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMEventsManagerScrollDocumentView.h"

@implementation AMEventsManagerScrollDocumentView {
    double curHeight;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //NSLog(@"scroll view frame size is: %f, %f", self.frame.size.width, self.frame.size.height);
        
        curHeight = 0;
    }
    
    return self;
}

- (void)awakeFromNib
{
}

- (void)drawRect:(NSRect)dirtyRect {
    
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)addRow:(GTLYouTubeLiveBroadcast *)theLiveEvent {
    
    //Add new Row to the Scroller Document View
    
    AMEventsManagerRowViewController *eventsVC = [[AMEventsManagerRowViewController alloc] initWithNibName:@"AMEventsManagerRowViewController" bundle:nil];
    NSView *rowView = [eventsVC view];
    eventsVC.eventDeleteCheckBox.liveBroadcast = theLiveEvent;
    [rowView setFrameOrigin:NSMakePoint(0, curHeight)];
    
    [eventsVC.eventTitleTextView setStringValue:theLiveEvent.snippet.title];
    
    [self addSubview:rowView];
    
    curHeight += rowView.frame.size.height;
    
    if (curHeight > self.frame.size.height) {
        //Need to make the document View taller to scroll and display all returned events
        NSSize newSize = NSMakeSize(self.enclosingScrollView.frame.size.width, (curHeight));
        [self setFrameSize:newSize];
    } else {
        // No need to resize document scroll view
    }
}

- (void)removeAllRows {
    [self setSubviews:[NSArray array]];
}

- (void)resetHeight {
    curHeight = 0;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
