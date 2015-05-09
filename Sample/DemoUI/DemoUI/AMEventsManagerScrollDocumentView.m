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
    [[NSColor redColor] setFill];
    NSRectFill(dirtyRect);
    
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)addRow:(GTLYouTubeLiveBroadcast *)theLiveEvent {
    //Add new Row to the Scroller Document View
    
    AMEventsManagerRowViewController *eventsVC = [[AMEventsManagerRowViewController alloc] initWithNibName:@"AMEventsManagerRowViewController" bundle:nil];
    NSView *rowView = [eventsVC view];
    [rowView setFrameOrigin:NSMakePoint(0, curHeight)];
    [self.eventsRows setObject:eventsVC forKey:theLiveEvent.identifier];
    
    [eventsVC.eventTitleTextView setStringValue:theLiveEvent.snippet.title];
    
    [self addSubview:rowView];
    
    curHeight += rowView.frame.size.height;
}

- (void)removeAllRows {
    [self.eventsRows removeAllObjects];
    [self setSubviews:[NSArray array]];
}

@end
