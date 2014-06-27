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


@interface AMGroupOutlineUserCellController ()

@end

@implementation AMGroupOutlineUserCellController

-(void)updateUI
{
    NSAssert([self.view isKindOfClass:[AMGroupOutlineUserCellView class]], @"internal error: the view is not AMGroupOutlineUserCellView");
    AMGroupOutlineUserCellView* cellView = (AMGroupOutlineUserCellView*)self.view;
    
    cellView.textField.stringValue = self.user.nickName;
    if (self.user.isOnline) {
        [cellView.imageView setImage:[NSImage imageNamed:@"user_offline"]];
    }else{
        [cellView.imageView setImage:[NSImage imageNamed:@"user_online"]];
    }
    
    if ([self.group.leaderId isEqualToString:self.user.userid]) {
        [cellView.leaderBtn setHidden:NO];
    }else{
        [cellView.leaderBtn setHidden:YES];
    }
    
    if (self.user.isOnline) {
        [cellView.zombieBtn setHidden:YES];
    }else{
        [cellView.zombieBtn setHidden:NO];
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
