//
//  AMGroupPanelViewController.m
//  DemoUI
//
//  Created by Wei Wang on 6/27/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupPanelViewController.h"
#import "AMMesher/AMAppObjects.h"
#import "AMMesher/AMGroup.h"
#import "AMGroupOutlineGroupCellController.h"
#import "AMGroupOutlineUserCellController.h"
#import "AMGroupOutlineRowView.h"
#import "AMGroupOutlineLabelCellController.h"

@interface AMGroupPanelViewController ()<NSOutlineViewDelegate, NSOutlineViewDataSource>
@property (weak) IBOutlet NSOutlineView *outlineView;
@end

@implementation AMGroupPanelViewController
{
    NSMutableArray* _userGroups;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)createControllerFromData
{
    _userGroups = [[NSMutableArray alloc] init];
    AMGroup* localGroup = [AMAppObjects appObjects][AMLocaGroupKey];
    
    AMGroupOutlineGroupCellController* localGroupController = [[AMGroupOutlineGroupCellController alloc] initWithNibName:@"AMGroupOutlineGroupCellController" bundle:nil];
    localGroupController.group = localGroup;
    localGroupController.userControllers = [[NSMutableArray alloc] init];
    
    for (AMUser* user in localGroup.users){
        AMGroupOutlineUserCellController* localUserController = [[AMGroupOutlineUserCellController alloc] initWithNibName:@"AMGroupOutlineUserCellController" bundle:nil];
        
        localUserController.group = localGroup;
        localUserController.user = user;
        
        [localGroupController.userControllers addObject:localUserController];
    }
    
    [_userGroups addObject:localGroupController];
    
    AMGroupOutlineLabelCellController* labelController = [[AMGroupOutlineLabelCellController alloc] initWithNibName:@"AMGroupOutlineLabelCellController" bundle:nil];
    labelController.groupControllers = [[NSMutableArray alloc] init];
    
    NSDictionary* remoteGroupDict = [AMAppObjects appObjects][AMRemoteGroupsKey];
    
    for (NSString* groupId in remoteGroupDict) {
        AMGroup* remoteGroup = remoteGroupDict[groupId];
        AMGroupOutlineGroupCellController* remoteGroupController = [[AMGroupOutlineGroupCellController alloc] initWithNibName:@"AMGroupOutlineGroupCellController" bundle:nil];
        remoteGroupController.group = remoteGroup;
        remoteGroupController.userControllers = [[NSMutableArray alloc] init];
        
        for (AMUser* user in remoteGroup.users){
            AMGroupOutlineUserCellController* localUserController = [[AMGroupOutlineUserCellController alloc] initWithNibName:@"AMGroupOutlineUserCellController" bundle:nil];
            
            localUserController.group = remoteGroup;
            localUserController.user = user;
            
            [remoteGroupController.userControllers addObject:localUserController];
        }
        
        [labelController.groupControllers addObject:remoteGroupController];
    }
    [_userGroups addObject:labelController];
}

-(void)awakeFromNib
{
    AMGroup* localGroup = [[AMGroup alloc] init];
    localGroup.groupId = [AMAppObjects creatUUID];
    localGroup.groupName = @"local group";
    localGroup.description = @"This is local group!";
    localGroup.password = @"";
    
    NSMutableArray* users = [[NSMutableArray alloc] init];
    
    AMUser* user1 = [[AMUser alloc] init];
    user1.userid = [AMAppObjects creatUUID];
    user1.nickName = @"www";
    user1.isOnline = NO;
    [users addObject:user1];
    
    AMUser* user2 = [[AMUser alloc] init];
    user2.userid = [AMAppObjects creatUUID];
    user2.nickName = @"www2";
    user2.isOnline = YES;
    [users addObject:user2];
    
    localGroup.users = users;
    localGroup.leaderId = user1.userid;
    localGroup.leaderName = user1.nickName;
    
    [AMAppObjects appObjects][AMLocaGroupKey] = localGroup;
    
    
    AMGroup* remoteGroup1 = [[AMGroup alloc] init];
    remoteGroup1.groupId = [AMAppObjects creatUUID];
    remoteGroup1.groupName = @"RemoteGroup";
    remoteGroup1.description = @"This is remote group1!";
    remoteGroup1.password = @"123456";
    
    NSMutableArray* remoteUsers1 = [[NSMutableArray alloc] init];
    
    AMUser* user3 = [[AMUser alloc] init];
    user3.userid = [AMAppObjects creatUUID];
    user3.nickName = @"KKK";
    user3.isOnline = YES;
    [remoteUsers1 addObject:user3];
    
    AMUser* user4 = [[AMUser alloc] init];
    user4.userid = [AMAppObjects creatUUID];
    user4.nickName = @"KKK2s";
    user4.isOnline = YES;
    [remoteUsers1 addObject:user4];
    
    remoteGroup1.users = remoteUsers1;
    remoteGroup1.leaderId = user4.userid;
    remoteGroup1.leaderName = user4.nickName;
    
    NSMutableDictionary* remoteGroups = [[NSMutableDictionary alloc] init];
    [remoteGroups setObject:remoteGroup1 forKey:remoteGroup1.groupId];
    
    [AMAppObjects appObjects][AMRemoteGroupsKey] = remoteGroups;
    
    
    [self createControllerFromData];
    self.outlineView.delegate = self;
    self.outlineView.dataSource  = self;
}


#pragma mark-
#pragma outlineView DataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return [_userGroups count];
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
    return [self outlineView:outlineView numberOfChildrenOfItem:item] > 0;
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
    }else if ([_userGroups count] != 0){
        return _userGroups[index];
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
        
        rowView.headImage = [NSImage imageNamed:@"group_online"];
        rowView.alterHeadImage = [NSImage imageNamed:@"group_online_expanded"];
        
    }else if([item isKindOfClass:[AMGroupOutlineGroupCellController class]]){
        
        AMGroupOutlineGroupCellController* groupController = (AMGroupOutlineGroupCellController*)item;
        NSString* groupId  = groupController.group.groupId;
        NSDictionary* meshedGroupDict = [AMAppObjects appObjects][AMMeshedGroupsKey];
        if (meshedGroupDict[groupId] != nil) {
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
