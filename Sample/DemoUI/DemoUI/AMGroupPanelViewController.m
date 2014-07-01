//
//  AMGroupPanelViewController.m
//  DemoUI
//
//  Created by Wei Wang on 6/27/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupPanelViewController.h"
#import "AMMesher/AMAppObjects.h"
#import "AMMesher/AMMesher.h"
#import "AMGroupOutlineGroupCellController.h"
#import "AMGroupOutlineUserCellController.h"
#import "AMGroupOutlineRowView.h"
#import "AMGroupOutlineLabelCellController.h"
#import "AMGroupPanelModel.h"
#import "AMGroupDetailsViewController.h"

@interface AMGroupPanelViewController ()<NSOutlineViewDelegate, NSOutlineViewDataSource>
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSView *detailView;
@property (weak) IBOutlet NSScrollView *outlineScrollView;

@end

@implementation AMGroupPanelViewController
{
    NSMutableArray* _userGroups;
    NSViewController* _detailViewController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)reloadGroups
{
    _userGroups = [[NSMutableArray alloc] init];
    AMGroup* localGroup = [AMAppObjects appObjects][AMLocalGroupKey];
    if (localGroup == nil) {
        return;
    }
    
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
    
    AMUser* mySelf = [AMAppObjects appObjects][AMMyselfKey];
    if (mySelf.isOnline == NO) {
        
        [self.outlineView reloadData];
        return;
    }
    
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
    
    [self.outlineView reloadData];
}

-(void)awakeFromNib
{
//    AMGroup* localGroup = [[AMGroup alloc] init];
//    localGroup.groupId = [AMAppObjects creatUUID];
//    localGroup.groupName = @"local group";
//    localGroup.description = @"This is local group!";
//    localGroup.password = @"";
//    
//    NSMutableArray* users = [[NSMutableArray alloc] init];
//    
//    AMUser* user1 = [[AMUser alloc] init];
//    user1.userid = [AMAppObjects creatUUID];
//    user1.nickName = @"www";
//    user1.isOnline = NO;
//    [users addObject:user1];
//    
//    AMUser* user2 = [[AMUser alloc] init];
//    user2.userid = [AMAppObjects creatUUID];
//    user2.nickName = @"www2";
//    user2.isOnline = YES;
//    [users addObject:user2];
//    
//    localGroup.users = users;
//    localGroup.leaderId = user1.userid;
//    
//    [AMAppObjects appObjects][AMLocalGroupKey] = localGroup;
//    
//    
//    AMGroup* remoteGroup1 = [[AMGroup alloc] init];
//    remoteGroup1.groupId = [AMAppObjects creatUUID];
//    remoteGroup1.groupName = @"RemoteGroup";
//    remoteGroup1.description = @"This is remote group1!";
//    remoteGroup1.password = @"123456";
//    
//    NSMutableArray* remoteUsers1 = [[NSMutableArray alloc] init];
//    
//    AMUser* user3 = [[AMUser alloc] init];
//    user3.userid = [AMAppObjects creatUUID];
//    user3.nickName = @"KKK";
//    user3.isOnline = YES;
//    [remoteUsers1 addObject:user3];
//    
//    AMUser* user4 = [[AMUser alloc] init];
//    user4.userid = [AMAppObjects creatUUID];
//    user4.nickName = @"KKK2s";
//    user4.isOnline = YES;
//    [remoteUsers1 addObject:user4];
//    
//    remoteGroup1.users = remoteUsers1;
//    remoteGroup1.leaderId = user4.userid;
//    
//    NSMutableDictionary* remoteGroups = [[NSMutableDictionary alloc] init];
//    [remoteGroups setObject:remoteGroup1 forKey:remoteGroup1.groupId];
//    
//    [AMAppObjects appObjects][AMRemoteGroupsKey] = remoteGroups;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadGroups) name:AM_LOCALUSERS_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadGroups) name:AM_REMOTEGROUPS_CHANGED object:nil];
    
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    [model addObserver:self forKeyPath:@"detailPanelState" options:NSKeyValueObservingOptionNew context:nil];
    
    [self reloadGroups];
    self.outlineView.delegate = self;
    self.outlineView.dataSource  = self;
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[AMGroupPanelModel sharedGroupModel] removeObserver:self];
}

-(void)hideDetailView
{
    NSRect rect = self.detailView.frame;
    rect.size.height = 0;
    
    [self.detailView setFrame:rect];
}

-(void)showGroupDetails
{
//    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
//    self.detailView. = model.selectedGroup
    if (_detailViewController) {
        [_detailViewController.view removeFromSuperview];
        _detailViewController = nil;
    }
    
//    _detailViewController = [[AMGroupDetailsViewController alloc] initWithNibName:@"AMGroupDetailsViewController" bundle:nil];
   
    NSRect scrollViewRect = self.outlineScrollView.frame;
    scrollViewRect.size.height -= 400;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.outlineScrollView setFrame:scrollViewRect];
    });
    
    
//    rect.origin.y = scrollViewRect.origin.y + scrollViewRect.size.height;
//    rect.size.height = 400;
    
    
    //[self.view addSubview:_detailViewController.view];
    //[_detailViewController.view setFrame:rect];
    
    [self.view setNeedsDisplay:YES];
}


#pragma mark -
#pragma   mark KVO
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if ([object isKindOfClass:[AMGroupPanelModel class]]){
        
        if ([keyPath isEqualToString:@"detailPanelState"]){
            
            DetailPanelState state =  [[change objectForKey:@"new"] intValue];
            switch (state) {
                case DetailPanelHide:
                    ;
                    break;
                case DetailPanelUser:
                    ;
                    break;
                case DetailPanelGroup:
                    [self showGroupDetails];
                    break;
                    
                default:
                    break;
            }
        }
    }
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
