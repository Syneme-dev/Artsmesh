//
//  AMStaticGroupOutlineCellViewController.m
//  DemoUI
//
//  Created by 王 为 on 7/10/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMStaticGroupOutlineCellViewController.h"
#import "AMGroupPanelModel.h"

@interface AMStaticGroupOutlineCellViewController ()

@end

@implementation AMStaticGroupOutlineCellViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
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

-(void)updateUI
{
    NSTableCellView* cellView = (NSTableCellView*)self.view;
    [cellView.imageView setHidden:YES];
    cellView.textField.stringValue = [self.staticGroup nickname];
    
}

-(void)removeTrackAres
{
    for ( NSTrackingArea* ta in [self.view trackingAreas]){
        [self.view removeTrackingArea:ta];
    }
}

-(void)dealloc
{
    [self removeTrackAres];
}


-(void)viewFrameChanged:(NSView*)view
{
    [self removeTrackAres];
    [self setTrackArea];
}

- (IBAction)socialBtnClicked:(NSButton *)sender
{
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    model.selectedStaticGroup = self.staticGroup;
    model.detailPanelState = DetailPanelStaticGroup;
}



@end
