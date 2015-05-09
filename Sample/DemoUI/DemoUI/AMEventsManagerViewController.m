//
//  AMEventsManagerViewController.m
//  Artsmesh
//
//  Created by Brad Phillips on 5/7/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMEventsManagerViewController.h"

@interface AMEventsManagerViewController ()

@end

@implementation AMEventsManagerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib {
    //NSView *scrollViewDocumentView = [[NSView alloc] initWithFrame:NSMakeRect(0, 180.0, 554.0, 180.0)];
    //[self.eventsListScrollView setDocumentView:scrollViewDocumentView];
    
    /**
    [self.eventsListScrollView setHasVerticalScroller:YES];
    [self.eventsListScrollView.documentView setFrameSize:NSMakeSize(554.0, 180.0)];
    **/
    
    AMEventsManagerScrollDocumentView *eventsDocumentView = [[AMEventsManagerScrollDocumentView alloc] initWithFrame:NSMakeRect(0, self.eventsListScrollView.frame.size.height, self.eventsListScrollView.frame.size.width, self.eventsListScrollView.frame.size.height)];
    
    [self.eventsListScrollView setDocumentView:eventsDocumentView];
    
}

- (void)setTitle:(NSString *)theTitle {
    [self.feedbackTitleTextField setStringValue:theTitle];
}

- (void)insertEvents:(GTLYouTubeChannelListResponse *)eventsList {
    [self.curLiveEvents removeAllObjects];
    [self.eventsRows removeAllObjects];
    
    for (GTLYouTubeLiveBroadcast *liveEvent in eventsList.items) {
        //Store Live Broadcast for later use
        [self.curLiveEvents setObject: liveEvent forKey:liveEvent.identifier];
        
        
        //Store Row View Controller for later use
        AMEventsManagerRowViewController *eventsVC = [[AMEventsManagerRowViewController alloc] initWithNibName:@"AMEventsManagerRowViewController" bundle:nil];
        NSView *rowView = [eventsVC view];
        [self.eventsRows setObject:eventsVC forKey:liveEvent.identifier];
        
        
        //Add a new row to the scroll view
        [self.eventsListScrollView.documentView addRow:liveEvent];
        
        NSLog(@"Insert this event now: %@", liveEvent.snippet.title);
        
        
    }
}

@end
