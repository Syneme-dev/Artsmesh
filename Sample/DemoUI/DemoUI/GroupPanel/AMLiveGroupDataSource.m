//
//  AMLiveGroupDataSource.m
//  DemoUI
//
//  Created by Wei Wang on 7/10/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMLiveGroupDataSource.h"
#import "AMGroupOutlineGroupCellController.h"
#import "AMGroupOutlineUserCellController.h"
#import "AMGroupOutlineLabelCellController.h"
#import "AMGroupOutlineRowView.h"
#import "AMGroupOutlineGroupCellView.h"
#import "AMGroupOutlineUserCellView.h"

@implementation AMLiveGroupDataSource

-(void)doubleClickOutlineView:(id)sender
{
    if([sender isKindOfClass:[NSOutlineView class]]){
        NSOutlineView* ov = (NSOutlineView*)sender;
        NSInteger selected = [ov selectedRow];
        
        if (selected < 0){
            return;
        }
        
        NSTableCellView *selectedCellView = [ov viewAtColumn:0 row:selected makeIfNecessary:YES];
        if ([selectedCellView isKindOfClass:[AMGroupOutlineGroupCellView class]]) {
            AMGroupOutlineGroupCellView* gCell = (AMGroupOutlineGroupCellView*)selectedCellView;
            [gCell.infoBtn performClick:gCell.infoBtn];
        }else if([selectedCellView isKindOfClass:[AMGroupOutlineUserCellView class]]){
            AMGroupOutlineUserCellView* uCell = (AMGroupOutlineUserCellView*)selectedCellView;
            [uCell.infoBtn performClick:uCell.infoBtn];
        }
    }
}

-(void)reloadGroups
{
    NSMutableArray* userGroups = [[NSMutableArray alloc] init];
    AMLiveGroup* localGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    if (localGroup == nil) {
        return;
    }
    
    AMGroupOutlineGroupCellController* localGroupController = [[AMGroupOutlineGroupCellController alloc] initWithNibName:@"AMGroupOutlineGroupCellController" bundle:nil];
    localGroupController.group = localGroup;
    localGroupController.editable = YES;
    localGroupController.userControllers = [[NSMutableArray alloc] init];
    
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    
    for (AMLiveUser* user in localGroup.users){
        AMGroupOutlineUserCellController* localUserController = [[AMGroupOutlineUserCellController alloc] initWithNibName:@"AMGroupOutlineUserCellController" bundle:nil];
        
        localUserController.group = localGroup;
        localUserController.user = user;
        if ([user.userid isEqualToString: mySelf.userid]) {
            localUserController.editable = YES;
        }else{
            localUserController.editable = NO;
        }
        
        localUserController.localUser = YES;
        
        [localGroupController.userControllers addObject:localUserController];
    }
    
    [userGroups addObject:localGroupController];
    
    if (mySelf.isOnline == NO) {
        self.liveGroups = userGroups;
        return;
    }
    
    AMGroupOutlineLabelCellController* labelController = [[AMGroupOutlineLabelCellController alloc] initWithNibName:@"AMGroupOutlineLabelCellController" bundle:nil];
    labelController.groupControllers = [[NSMutableArray alloc] init];
    [userGroups addObject:labelController];
    
    for (AMLiveGroup* remoteGroup in [AMCoreData shareInstance].remoteLiveGroups) {
        AMGroupOutlineGroupCellController* remoteGroupController = [[AMGroupOutlineGroupCellController alloc] initWithNibName:@"AMGroupOutlineGroupCellController" bundle:nil];
        remoteGroupController.group = remoteGroup;
        remoteGroupController.userControllers = [[NSMutableArray alloc] init];
        remoteGroupController.editable = NO;
        
        for (AMLiveUser* user in remoteGroup.users){
            AMGroupOutlineUserCellController* remoteUserController = [[AMGroupOutlineUserCellController alloc] initWithNibName:@"AMGroupOutlineUserCellController" bundle:nil];
            
            remoteUserController.group = remoteGroup;
            remoteUserController.user = user;
            remoteUserController.editable = NO;
            remoteUserController.localUser = NO;
            
            [remoteGroupController.userControllers addObject:remoteUserController];
        }
        
        [labelController.groupControllers addObject:remoteGroupController];
    }
    
    self.liveGroups = userGroups;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return [self.liveGroups count];
    }else if([item isKindOfClass:[AMGroupOutlineGroupCellController class]]){
        AMGroupOutlineGroupCellController* groupController = (AMGroupOutlineGroupCellController*)item;
        return [groupController.userControllers count];
    }else if ([item isKindOfClass:[AMGroupOutlineLabelCellController class]]){
        AMGroupOutlineLabelCellController* labelController = (AMGroupOutlineLabelCellController*)item;
        return [labelController.groupControllers count];
    }else{
        return 0;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    long i =  [self outlineView:outlineView numberOfChildrenOfItem:item];
    return i > 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (item != nil) {
        if ([item isKindOfClass:[AMGroupOutlineGroupCellController class]]) {
            AMGroupOutlineGroupCellController* groupController = (AMGroupOutlineGroupCellController*)item;
            return [groupController.userControllers objectAtIndex:index];
        }else if([item isKindOfClass:[AMGroupOutlineLabelCellController class]]){
            AMGroupOutlineLabelCellController* labelController = (AMGroupOutlineLabelCellController*)item;
            return [labelController.groupControllers objectAtIndex:index];
        }
    }else if ([self.liveGroups count] != 0){
        return self.liveGroups[index];
    }
    
    return nil;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    
    if ([item isKindOfClass:[AMGroupOutlineGroupCellController class]]) {
        AMGroupOutlineGroupCellController* groupController = (AMGroupOutlineGroupCellController*)item;
        [groupController updateUI];
        [groupController setTrackArea];
        
        return groupController.view;
        
    }else if([item isKindOfClass:[AMGroupOutlineUserCellController class]]){
        AMGroupOutlineUserCellController* userController = (AMGroupOutlineUserCellController*)item;
        [userController updateUI];
        [userController setTrackArea];
        
        return userController.view;
        
    }else if([item isKindOfClass:[AMGroupOutlineLabelCellController class]]){
        AMGroupOutlineLabelCellController* labelController = (AMGroupOutlineLabelCellController*)item;
        [labelController updateUI];
        
        return labelController.view;
    }
    
    return nil;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
    if ([item isKindOfClass:[NSViewController class]]) {
        NSViewController* controller = (NSViewController*) item;
        NSView* cellView = controller.view;
        
        return cellView.frame.size.height;
    }
    
    return 0.0;
}

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item
{
    AMGroupOutlineRowView* rowView = [[AMGroupOutlineRowView alloc] init];
    
    if ([item isKindOfClass:[AMGroupOutlineLabelCellController class]]) {
        
        rowView.headImage = [NSImage imageNamed:@"artsmesh_bar"];
        rowView.alterHeadImage = [NSImage imageNamed:@"artsmesh_bar_expanded"];
        
    }else if([item isKindOfClass:[AMGroupOutlineGroupCellController class]]){
        
        AMGroupOutlineGroupCellController* groupController = (AMGroupOutlineGroupCellController*)item;
        if ([groupController.group isMeshed]) {
            rowView.headImage = [NSImage imageNamed:@"group_online"];
            rowView.alterHeadImage = [NSImage imageNamed:@"group_online_expanded"];
        }else{
            rowView.headImage = [NSImage imageNamed:@"group_offline"];
            rowView.alterHeadImage = [NSImage imageNamed:@"group_offline_expanded"];
        }
    }
    
    return rowView;
}


@end
