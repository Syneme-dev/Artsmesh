//
//  AMLiveGroupDataSource.m
//  DemoUI
//
//  Created by Wei Wang on 7/10/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMLiveGroupDataSource.h"
#import "AMGroupPanelTableCellController.h"
#import "AMGroupPanelGroupCellController.h"
#import "AMGroupPanelUserCellController.h"
#import "AMGroupPanelLabelCellController.h"
#import "AMGroupOutlineRowView.h"
#import "AMGroupPanelTableCellView.h"

@implementation AMLiveGroupDataSource
{
     NSMutableArray* _expanededNodes;
}

-(void)doubleClickOutlineView:(id)sender
{
    if([sender isKindOfClass:[NSOutlineView class]]){
        NSOutlineView* ov = (NSOutlineView*)sender;
        NSInteger selected = [ov selectedRow];
        
        if (selected < 0){
            return;
        }
        
        AMGroupPanelTableCellView *selectedCellView = [ov viewAtColumn:0 row:selected makeIfNecessary:YES];
        [selectedCellView doubleClicked:self];
    }
}

-(void)reloadGroups
{
    NSMutableArray* userGroups = [[NSMutableArray alloc] init];
    AMLiveGroup* localGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    if (localGroup == nil) {
        return;
    }
    
    AMGroupPanelGroupCellController* localGroupController = [[AMGroupPanelGroupCellController alloc] initWithNibName:@"AMGroupPanelGroupCellController" bundle:nil];
    
    localGroupController.group = localGroup;
    localGroupController.nodeItemIdentifier = @"localGroupController";
    localGroupController.isExpanded = YES;
    localGroupController.childrenNodeItem = [[NSMutableArray alloc] init];
    
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    
    for (AMLiveUser* user in localGroup.users){
        AMGroupPanelUserCellController* localUserController = [[AMGroupPanelUserCellController alloc] initWithNibName:@"AMGroupPanelUserCellController" bundle:nil];
        
        localUserController.group = localGroup;
        localUserController.user = user;
        localUserController.localUser = YES;
        localUserController.nodeItemIdentifier = user.userid;
        localUserController.isExpanded = NO;
        
        [localGroupController.childrenNodeItem addObject:localUserController];
    }
    
    [userGroups addObject:localGroupController];
    
    if (mySelf.isOnline == NO) {
        self.liveGroups = userGroups;
        return;
    }
    
    AMGroupPanelLabelCellController* labelController = [[AMGroupPanelLabelCellController alloc] initWithNibName:@"AMGroupPanelLabelCellController" bundle:nil];
    labelController.childrenNodeItem = [[NSMutableArray alloc] init];
    labelController.nodeItemIdentifier = @"AMLabelController";
    labelController.isExpanded = YES;
    
    [userGroups addObject:labelController];
    
    for (AMLiveGroup* remoteGroup in [AMCoreData shareInstance].remoteLiveGroups) {
        AMGroupPanelGroupCellController* remoteGroupController = [[AMGroupPanelGroupCellController alloc] initWithNibName:@"AMGroupPanelGroupCellController" bundle:nil];
        remoteGroupController.group = remoteGroup;
        remoteGroupController.nodeItemIdentifier = remoteGroup.groupId;
        remoteGroupController.isExpanded = [self isControllerExpanded:remoteGroup.groupId];
        remoteGroupController.childrenNodeItem = [[NSMutableArray alloc] init];
        
        
        NSArray* allUsers = [remoteGroup usersIncludeSubGroup];
        for (AMLiveUser* user in allUsers){
            AMGroupPanelUserCellController* remoteUserController = [[AMGroupPanelUserCellController alloc] initWithNibName:@"AMGroupPanelUserCellController" bundle:nil];
            
            remoteUserController.group = remoteGroup;
            remoteUserController.user = user;
            remoteUserController.localUser = NO;
            remoteUserController.nodeItemIdentifier = user.userid;
            remoteUserController.isExpanded = NO;
            
            [remoteGroupController.childrenNodeItem addObject:remoteUserController];
        }
        
        [labelController.childrenNodeItem addObject:remoteGroupController];
    }
    
    self.liveGroups = userGroups;
}

-(NSMutableArray*)expandedNodes
{
    if (_expanededNodes == nil) {
        _expanededNodes = [[NSMutableArray alloc] init];
    }
    
    return _expanededNodes;
}

-(BOOL)isControllerExpanded:(NSString*)gId
{
    for (NSString* expanedId in _expanededNodes) {
        if ([expanedId isEqualTo:gId]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return [self.liveGroups count];
    }else if([item isKindOfClass:[AMGroupPanelTableCellController class]]){
        AMGroupPanelTableCellController* tableCellController = (AMGroupPanelTableCellController*)item;
        return [tableCellController.childrenNodeItem count];
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
        if ([item isKindOfClass:[AMGroupPanelTableCellController class]]) {
            AMGroupPanelTableCellController* tableCellController = (AMGroupPanelTableCellController*)item;
            return [tableCellController.childrenNodeItem objectAtIndex:index];
        }
    }else if ([self.liveGroups count] != 0){
        return self.liveGroups[index];
    }
    
    return nil;
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification
{
     AMGroupPanelTableCellController* controller = [[notification userInfo]valueForKey:@"NSObject"];
    if (controller != nil){
        controller.isExpanded = YES;
        [[self expandedNodes] addObject:controller.nodeItemIdentifier];
    }
}

-(void)outlineViewItemDidCollapse:(NSNotification *)notification
{
     AMGroupPanelTableCellController* controller = [[notification userInfo]valueForKey:@"NSObject"];
    if (controller != nil){
        controller.isExpanded = NO;
        [[self expandedNodes] removeObject:controller.nodeItemIdentifier];
    }
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    
    if ([item isKindOfClass:[AMGroupPanelTableCellController class]]) {
        AMGroupPanelTableCellController* tableCellController = (AMGroupPanelTableCellController*)item;
        [tableCellController updateUI];
        [tableCellController setTrackArea];
        
        return tableCellController.view;
        
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
    
    if ([item isKindOfClass:[AMGroupPanelLabelCellController class]]) {
        
        rowView.headImage = [NSImage imageNamed:@"artsmesh_bar"];
        rowView.alterHeadImage = [NSImage imageNamed:@"artsmesh_bar_expanded"];
        
    }else if([item isKindOfClass:[AMGroupPanelGroupCellController class]]){
        
        AMGroupPanelGroupCellController* groupController = (AMGroupPanelGroupCellController*)item;
        if ([groupController.group isMeshed]) {
            if (groupController.group.busy) {
                rowView.headImage = [NSImage imageNamed:@"live_group_busy_vertical"];
                rowView.alterHeadImage = [NSImage imageNamed:@"live_group_busy_horizen"];
            }else{
                rowView.headImage = [NSImage imageNamed:@"group_online"];
                rowView.alterHeadImage = [NSImage imageNamed:@"group_online_expanded"];
            }
        }else{
            rowView.headImage = [NSImage imageNamed:@"group_offline"];
            rowView.alterHeadImage = [NSImage imageNamed:@"group_offline_expanded"];
        }
    }
    
    return rowView;
}


@end
