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
    eventsVC.eventEditCheckBox.liveBroadcast = theLiveEvent;
    [rowView setFrameOrigin:NSMakePoint(0, curHeight)];
    
    [eventsVC.eventTitleTextView setStringValue:theLiveEvent.snippet.title];
    
    [self addSubview:rowView];
    
    curHeight += rowView.frame.size.height;
    
    NSLog(@"Current Height is: %f, Doc View Height is: %f", curHeight, self.frame.size.height);
    
    if (curHeight > self.frame.size.height) {
        NSLog(@"need to make the document view taller to fit all the items.");
        NSSize newSize = NSMakeSize(self.enclosingScrollView.frame.size.width, (curHeight));
        [self setFrameSize:newSize];
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
