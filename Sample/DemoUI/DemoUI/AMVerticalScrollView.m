//
//  AMVerticalScrollView
//  Artsmesh
//
//  Created by KeysXu on 6/21/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMVerticalScrollView.h"

@implementation AMVerticalScrollView

- (void)drawRect:(NSRect)dirtyRect {
    [self.documentView setBackgroundColor:[AMTheme sharedInstance].colorBackground];
    
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        [self hideScrollers];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self hideScrollers];
}

- (void)hideScrollers
{
    // Hide the scrollers. You may want to do this if you're syncing the scrolling
    // this NSScrollView with another one.
    [self setHasHorizontalScroller:NO];
    [self setHasVerticalScroller:YES];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    if(theEvent.deltaX>4||theEvent.deltaX<-4){
//         [super scrollWheel:theEvent];
    [self.superview scrollWheel:theEvent];
        
        }
    else{
        [super scrollWheel:theEvent];
    }
//     Do nothing: disable scrolling altogether
}

@end
