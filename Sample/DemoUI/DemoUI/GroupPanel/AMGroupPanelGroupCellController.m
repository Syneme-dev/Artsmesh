//
//  AMGroupOutlineGroupCellController.m
//  AMGroupOutlineTest
//
//  Created by 王 为 on 6/27/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import "AMGroupPanelGroupCellController.h"
#import "AMGroupPanelTableCellView.h"
#import "UIFramework/AMFoundryFontView.h"
#import "AMGroupPanelModel.h"
#import "AMMesher/AMMesher.h"

#define MAX_GROUP_NAME_LENGTH 16
#define MAX_GROUP_DESCRIPTION 64

@interface AMGroupPanelGroupCellController ()<NSTextFieldDelegate>
@property (weak) IBOutlet NSButton *lockBtn;
@property (weak) IBOutlet NSButton *messageBtn;
@property (weak) IBOutlet NSButton *mergeBtn;
@property (weak) IBOutlet NSButton *leaveBtn;
@property (weak) IBOutlet NSButton *infoBtn;

@end

@implementation AMGroupPanelGroupCellController

-(void)awakeFromNib
{
    [super awakeFromNib];
}


-(void)updateUI
{
    AMGroupPanelTableCellView* cellView = (AMGroupPanelTableCellView*)self.view;
    cellView.textField.stringValue = self.group.groupName;
    [cellView.imageView setHidden:YES];
    [cellView.textField setEditable:NO];
    
    if ([self.group.password isEqualToString:@""]) {
        [self.lockBtn setHidden:YES];
    }else{
        [self.lockBtn setHidden:NO];
    }
    
    if ([[self.group messages] count] == 0) {
        [self.messageBtn setHidden:YES];
    }else{
        [self.messageBtn setHidden:NO];
    }

    [self.infoBtn setHidden:YES];
    [self.leaveBtn setHidden:YES];
    [self.mergeBtn setHidden:YES];
}

- (IBAction)infoBtnClick:(id)sender
{
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    model.selectedGroup = self.group;
    model.detailPanelState = DetailPanelGroup;
}

- (IBAction)mergeBtnClick:(id)sender
{
    [[AMMesher sharedAMMesher] mergeGroup:self.group.groupId];
}

- (IBAction)leaveBtnClick:(id)sender
{
    [[AMMesher sharedAMMesher] mergeGroup:@""];
}

-(void)cellViewDoubleClicked:(id)sender
{
    [self.infoBtn performClick:sender];
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
    [self.infoBtn setHidden:NO];
    
    NSString* mergedGroupId = [AMCoreData shareInstance].mergedGroupId;
    AMLiveGroup* myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    
    if ([myGroup.groupId isEqualToString:self.group.groupId ]){
        [self.mergeBtn setHidden:YES];
        [self.leaveBtn setHidden:YES];
    }else if([self.group.groupId isEqualToString:mergedGroupId]){
        [self.mergeBtn setHidden:YES];
        [self.leaveBtn setHidden:NO];
    }else{
        [self.mergeBtn setHidden:NO];
        [self.leaveBtn setHidden:YES];
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [self.infoBtn setHidden:YES];
    [self.leaveBtn setHidden:YES];
    [self.mergeBtn setHidden:YES];
}

#pragma mark-
#pragma NSTextField Delegate

-(BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
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
