//
//  AMGroupOutlineUserCellController.m
//  AMGroupOutlineTest
//
//  Created by 王 为 on 6/27/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import "AMGroupOutlineUserCellController.h"
#import "AMGroupOutlineUserCellView.h"
#import "AMMesher/AMAppObjects.h"
#import "AMGroupPanelModel.h"
#import "AMGroupTextFieldFormatter.h"
#import "AMMesher/AMMesher.h"
#import "AMPreferenceManager/AMPreferenceManager.h"

#define MAX_USER_NAME_LENGTH 16

@interface AMGroupOutlineUserCellController ()

@end

@implementation AMGroupOutlineUserCellController

-(void)awakeFromNib
{
    AMGroupOutlineUserCellView* cellView = (AMGroupOutlineUserCellView*)self.view;
    AMGroupTextFieldFormatter* formatter = cellView.textField.formatter;
    [formatter setMaximumLength:MAX_USER_NAME_LENGTH];
    
    cellView.delegate = self;
    [cellView.textField setEditable:NO];
    [cellView.textField setSelectable:NO];
}

-(void)updateUI
{
    NSAssert([self.view isKindOfClass:[AMGroupOutlineUserCellView class]], @"internal error: the view is not AMGroupOutlineUserCellView");
    AMGroupOutlineUserCellView* cellView = (AMGroupOutlineUserCellView*)self.view;
  
    [cellView.textField setEditable:NO];

    cellView.textField.stringValue = self.user.nickName;
    if (self.user.isOnline) {
        [cellView.imageView setImage:[NSImage imageNamed:@"user_online"]];
    }else{
        [cellView.imageView setImage:[NSImage imageNamed:@"user_offline"]];
    }
    
    if ([self.group.leaderId isEqualToString:self.user.userid]) {
        [cellView.leaderBtn setHidden:NO];
    }else{
        [cellView.leaderBtn setHidden:YES];
    }
    
    if (self.user.isOnline && self.localUser) {
        [cellView.zombieBtn setHidden:NO];
    }else{
        [cellView.zombieBtn setHidden:YES];
    }
    
    [cellView.infoBtn setHidden:YES];
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

-(void)dealloc
{
    [self removeTrackAres];
}


- (IBAction)infoBtnClick:(id)sender
{
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    model.selectedUser = self.user;
    model.detailPanelState = DetailPanelUser;
}

-(void)viewFrameChanged:(NSView*)view
{
    [self removeTrackAres];
    [self setTrackArea];
}


#pragma mark-
#pragma TableViewCell Tracking Area
- (void)mouseEntered:(NSEvent *)theEvent
{
    AMGroupOutlineUserCellView* cellView = (AMGroupOutlineUserCellView*)self.view;
    [cellView.infoBtn setHidden:NO];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    AMGroupOutlineUserCellView* cellView = (AMGroupOutlineUserCellView*)self.view;
    [cellView.infoBtn setHidden:YES];
}


@end
