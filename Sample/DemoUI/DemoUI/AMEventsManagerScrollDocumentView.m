//
//  AMEventsManagerScrollDocumentView.m
//  Artsmesh
//
//  Created by Brad Phillips on 5/8/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMEventsManagerScrollDocumentView.h"

@implementation AMEventsManagerScrollDocumentView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSLog(@"scroll view frame size is: %f, %f", self.frame.size.width, self.frame.size.height);
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
    NSLog(@"Add row view now..");
    
    AMEventsManagerRowViewController *eventsVC = [[AMEventsManagerRowViewController alloc] initWithNibName:@"AMEventsManagerRowViewController" bundle:nil];
    NSView *rowView = [eventsVC view];
    [self.eventsRows setObject:eventsVC forKey:theLiveEvent.identifier];
    
     
    [self addSubview:rowView];
    
}

@end
