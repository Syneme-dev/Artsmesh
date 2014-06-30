//
//  AMGroupOutlineGroupCellController.m
//  AMGroupOutlineTest
//
//  Created by 王 为 on 6/27/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import "AMGroupOutlineGroupCellController.h"
#import "AMMesher/AMAppObjects.h"
#import "AMGroupOutlineGroupCellView.h"
#import "UIFramework/AMFoundryFontView.h"

@interface AMGroupOutlineGroupCellController ()

@end

@implementation AMGroupOutlineGroupCellController

-(void)updateUI
{
    NSAssert([self.view isKindOfClass:[AMGroupOutlineGroupCellView class]], @"internal error: the view is not AMGroupOutlineGroupCellView");
    AMGroupOutlineGroupCellView* cellView = (AMGroupOutlineGroupCellView*)self.view;
    
    cellView.textField.stringValue = self.group.groupName;
    cellView.descriptionField.stringValue = self.group.description;
    
//    NSDictionary* meshedGroup = [AMAppObjects appObjects][AMMeshedGroupsKey];
//    if (meshedGroup[self.group.groupId] == nil ) {
//        [cellView.imageView setImage:[NSImage imageNamed:@"user_offline"]];
//    }else{
//        [cellView.imageView setImage:[NSImage imageNamed:@"user_online"]];
//    }
    
    if ([self.group.password isEqualToString:@""]) {
        [cellView.lockBtn setHidden:YES];
    }else{
        [cellView.lockBtn setHidden:NO];
    }
    
    NSDictionary* groupMsgDict = [AMAppObjects appObjects][AMGroupMessageKey];
    if ([groupMsgDict[self.group.groupId] count] == 0) {
        [cellView.messageBtn setHidden:YES];
    }else{
        [cellView.messageBtn setHidden:NO];
    }
    
    [cellView.imageView setHidden:YES];
    [cellView.infoBtn setHidden:YES];
    [cellView.leaveBtn setHidden:YES];
    [cellView.mergeBtn setHidden:YES];
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
    AMGroupOutlineGroupCellView* cellView = (AMGroupOutlineGroupCellView*)self.view;
    [cellView.infoBtn setHidden:NO];
    
    NSString* mergedGroupId = [AMAppObjects appObjects][AMMergedGroupIdKey];
    
    AMGroup* myGroup = [AMAppObjects appObjects][AMLocaGroupKey];
    if ([myGroup.groupId isEqualToString:self.group.groupId ]){
        [cellView.mergeBtn setHidden:YES];
        [cellView.leaveBtn setHidden:YES];
    }else if([self.group.groupId isEqualToString:mergedGroupId]){
        [cellView.mergeBtn setHidden:YES];
        [cellView.leaveBtn setHidden:NO];
    }else{
        [cellView.mergeBtn setHidden:NO];
        [cellView.leaveBtn setHidden:YES];
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    AMGroupOutlineGroupCellView* cellView = (AMGroupOutlineGroupCellView*)self.view;
    [cellView.infoBtn setHidden:YES];
    [cellView.leaveBtn setHidden:YES];
    [cellView.mergeBtn setHidden:YES];
}


@end
