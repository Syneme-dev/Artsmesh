//
//  AMGroupPanelTableCellController.m
//  DemoUI
//
//  Created by Wei Wang on 7/22/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupPanelTableCellController.h"
#import "AMGroupTextFieldFormatter.h"
#import "AMGroupPanelTableCellView.h"

#define MAX_GROUP_NAME_LENGTH 16
#define MAX_GROUP_DESCRIPTION 64

@interface AMGroupPanelTableCellController ()

@end

@implementation AMGroupPanelTableCellController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib
{
    AMGroupPanelTableCellView* cellView = (AMGroupPanelTableCellView*)self.view;
    cellView.delegate = self;
}

-(void)setTrackArea
{
    if ([[self.view trackingAreas] count] == 0) {
        NSRect rect = [self.view bounds];
        NSTrackingArea* trackArea = [[NSTrackingArea alloc]
                                     initWithRect:rect
                                     options:(NSTrackingMouseEnteredAndExited  | NSTrackingMouseMoved|NSTrackingActiveInKeyWindow )
                                     owner:self
                                     userInfo:nil];
        [self.view addTrackingArea:trackArea];
    }
}

-(void)removeTrackAres
{
    for ( NSTrackingArea* ta in [self.view trackingAreas]){
        [self.view removeTrackingArea:ta];
    }
}

-(void)updateUI
{
    
}

-(void)cellViewDoubleClicked:(id)sender
{
    return;
}

#pragma mark-
#pragma TableViewCell FrameChanged

-(void)viewFrameChanged:(NSView*)view
{
    [self removeTrackAres];
    [self setTrackArea];
}


#pragma mark-
#pragma TableViewCell Tracking Area
- (void)mouseEntered:(NSEvent *)theEvent
{

}

- (void)mouseExited:(NSEvent *)theEvent
{
    
}


@end
