//
//  AMStaticGroupOutlineCellViewController.m
//  DemoUI
//
//  Created by 王 为 on 7/10/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMStaticGroupOutlineCellViewController.h"
#import "AMGroupPanelModel.h"
#import "AMStaticGroupOutlineCellView.h"
#import <AMNotificationManager/AMNotificationManager.h>

@interface AMStaticGroupOutlineCellViewController ()

@end

@implementation AMStaticGroupOutlineCellViewController

-(void)awakeFromNib
{
    AMStaticGroupOutlineCellView* cellView = (AMStaticGroupOutlineCellView*)self.view;
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

-(void)updateUI
{
    AMStaticGroupOutlineCellView* cellView = (AMStaticGroupOutlineCellView*)self.view;
    [cellView.imageView setHidden:YES];
    cellView.textField.stringValue = [self.staticGroup nickname];
    [cellView.socialBtn setHidden:YES];
    [cellView.infoBtn setHidden:YES];
    
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
    NSString* groupName = self.staticGroup.nickname;
    NSDictionary *userInfo= [[NSDictionary alloc] initWithObjectsAndKeys:
                             groupName , @"GroupName", nil];
    [AMN_NOTIFICATION_MANAGER postMessage:userInfo withTypeName:AMN_SHOWGROUPINFO source:self];
}

- (IBAction)infoBtnClicked:(NSButton *)sender
{
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    model.selectedStaticGroup = self.staticGroup;
    model.detailPanelState = DetailPanelStaticGroup;
}

#pragma mark-
#pragma TableViewCell Tracking Area
- (void)mouseEntered:(NSEvent *)theEvent
{
    AMStaticGroupOutlineCellView* cellView = (AMStaticGroupOutlineCellView*)self.view;
    [cellView.socialBtn setHidden:NO];
    [cellView.infoBtn setHidden:NO];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    AMStaticGroupOutlineCellView* cellView = (AMStaticGroupOutlineCellView*)self.view;
    [cellView.socialBtn setHidden:YES];
    [cellView.infoBtn setHidden:YES];
}




@end
