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
#import "AMGroupPanelModel.h"
#import "AMMesher/AMMesher.h"
#import "AMGroupTextFieldFormatter.h"

#define MAX_GROUP_NAME_LENGTH 16
#define MAX_GROUP_DESCRIPTION 64

@interface AMGroupOutlineGroupCellController ()<NSTextFieldDelegate>

@end

@implementation AMGroupOutlineGroupCellController

-(void)awakeFromNib
{
    AMGroupOutlineGroupCellView* cellView = (AMGroupOutlineGroupCellView*)self.view;
    AMGroupTextFieldFormatter* formatter = cellView.textField.formatter;
    [formatter setMaximumLength:MAX_GROUP_NAME_LENGTH];
    
    AMGroupTextFieldFormatter* desFormatter = cellView.descriptionField.formatter;
    [desFormatter setMaximumLength:MAX_GROUP_DESCRIPTION];
}


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
    
    if ([[self.group messages] count] == 0) {
        [cellView.messageBtn setHidden:YES];
    }else{
        [cellView.messageBtn setHidden:NO];
    }
    
    [cellView.imageView setHidden:YES];
    [cellView.infoBtn setHidden:YES];
    [cellView.leaveBtn setHidden:YES];
    [cellView.mergeBtn setHidden:YES];
    
    if (self.editable){
        [cellView.textField setEditable:YES];
        [cellView.descriptionField setEditable:YES];
    }else{
        [cellView.textField setEditable:NO];
        [cellView.descriptionField setEditable:NO];
    }
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
    model.selectedGroup = self.group;
    model.detailPanelState = DetailPanelGroup;
}

- (IBAction)mergeBtnClick:(id)sender
{
    AMMesher* mesher = [AMMesher sharedAMMesher];
    [mesher mergeGroup:self.group.groupId];
}

- (IBAction)leaveBtnClick:(id)sender
{
    AMMesher* mesher = [AMMesher sharedAMMesher];
    [mesher unmergeGroup];
}

- (IBAction)groupNameEdited:(NSTextField *)sender
{
    AMGroup* myLocalGroup = [AMAppObjects appObjects][AMLocalGroupKey];
    
    NSString* newGroupName = sender.stringValue;
    if ([newGroupName isEqualToString:myLocalGroup.groupName] ) {
        return;
    }
    
    myLocalGroup.groupName = newGroupName;
    
    AMMesher* mesher = [AMMesher sharedAMMesher];
    [mesher updateGroup];
}

- (IBAction)groupDescriptionEdited:(NSTextField *)sender
{
    AMGroup* myLocalGroup = [AMAppObjects appObjects][AMLocalGroupKey];
    
    NSString* newDescripton = sender.stringValue;
    if ([newDescripton isEqualToString:myLocalGroup.description] ) {
        return;
    }
    
    myLocalGroup.description = newDescripton;
    
    AMMesher* mesher = [AMMesher sharedAMMesher];
    [mesher updateGroup];
}

-(void)doubleClicked:(id)sender
{
    
}

#pragma mark-
#pragma TableViewCell Tracking Area
- (void)mouseEntered:(NSEvent *)theEvent
{
    AMGroupOutlineGroupCellView* cellView = (AMGroupOutlineGroupCellView*)self.view;
    [cellView.infoBtn setHidden:NO];
    
    NSString* mergedGroupId = [AMAppObjects appObjects][AMMergedGroupIdKey];
    
    AMGroup* myGroup = [AMAppObjects appObjects][AMLocalGroupKey];
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

#pragma mark-
#pragma NSTextField Delegate

-(BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//            self.myPopOver = [[NSPopover alloc] init];
//            self.myPopOver.animates = YES;
//            self.myPopOver.contentViewController = [[AMErrPopoverViewController alloc] initWithNibName:@"AMErrPopoverViewController" bundle:nil];
//        
//            [self.myPopOver showRelativeToRect:[control bounds] ofView:control preferredEdge:NSMaxXEdge];
//    });
    
    if ([control.identifier isEqualToString:@"group_name_field"]) {
        NSTextField* groupNameField = (NSTextField*)control;
        
        NSString* groupName = groupNameField.stringValue;
        if (groupName.length > 16) {
            
            return NO;
        }
    }
    
    return YES;
}


@end
