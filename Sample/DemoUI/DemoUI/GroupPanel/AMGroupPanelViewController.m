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
#import "UIFramework/BlueBackgroundView.h"
#import "AMUserDetailsViewController.h"
#import "AMGroupOutlineGroupCellView.h"
#import "AMGroupOutlineUserCellView.h"

@interface AMGroupPanelViewController ()<NSOutlineViewDelegate, NSOutlineViewDataSource>
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSScrollView *outlineScrollView;
@property (weak) IBOutlet BlueBackgroundView *topboundView;

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
    _userGroups = [[NSMutableArray alloc] init];
    AMGroup* localGroup = [AMAppObjects appObjects][AMLocalGroupKey];
    if (localGroup == nil) {
        return;
    }
    
    AMGroupOutlineGroupCellController* localGroupController = [[AMGroupOutlineGroupCellController alloc] initWithNibName:@"AMGroupOutlineGroupCellController" bundle:nil];
    localGroupController.group = localGroup;
    localGroupController.editable = YES;
    localGroupController.userControllers = [[NSMutableArray alloc] init];
    
    AMUser* mySelf = [AMAppObjects appObjects][AMMyselfKey];
    
    for (AMUser* user in localGroup.users){
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
    
    [_userGroups addObject:localGroupController];
    
    if (mySelf.isOnline == NO) {
        
        [self.outlineView reloadData];
        [self.outlineView expandItem:nil expandChildren:YES];
        return;
    }
    
    AMGroupOutlineLabelCellController* labelController = [[AMGroupOutlineLabelCellController alloc] initWithNibName:@"AMGroupOutlineLabelCellController" bundle:nil];
    labelController.groupControllers = [[NSMutableArray alloc] init];
    [_userGroups addObject:labelController];
    
    NSDictionary* remoteGroupDict = [AMAppObjects appObjects][AMRemoteGroupsKey];
    
    for (NSString* groupId in remoteGroupDict) {
        AMGroup* remoteGroup = remoteGroupDict[groupId];
        AMGroupOutlineGroupCellController* remoteGroupController = [[AMGroupOutlineGroupCellController alloc] initWithNibName:@"AMGroupOutlineGroupCellController" bundle:nil];
        remoteGroupController.group = remoteGroup;
        remoteGroupController.userControllers = [[NSMutableArray alloc] init];
        remoteGroupController.editable = NO;
        
        for (AMUser* user in remoteGroup.users){
            AMGroupOutlineUserCellController* remoteUserController = [[AMGroupOutlineUserCellController alloc] initWithNibName:@"AMGroupOutlineUserCellController" bundle:nil];
            
            remoteUserController.group = remoteGroup;
            remoteUserController.user = user;
            remoteUserController.editable = NO;
            remoteUserController.localUser = NO;
            
            [remoteGroupController.userControllers addObject:remoteUserController];
        }
        
        [labelController.groupControllers addObject:remoteGroupController];
    }
   
    
    [self.outlineView reloadData];
    [self.outlineView expandItem:nil expandChildren:YES];
}

-(void) awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadGroups) name:AM_LOCALUSERS_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadGroups) name:AM_REMOTEGROUPS_CHANGED object:nil];
    
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    [model addObserver:self forKeyPath:@"detailPanelState" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld  context:nil];
    
    [self reloadGroups];
    self.outlineView.delegate = self;
    self.outlineView.dataSource  = self;
    
    [self.outlineView setTarget:self];
    [self.outlineView setDoubleAction:@selector(doubleClickOutlineView:)];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[AMGroupPanelModel sharedGroupModel] removeObserver:self];
}

-(void)hideDetailView
{
    if (_detailViewController) {
        [_detailViewController.view removeFromSuperview];
        _detailViewController = nil;
    }
    
    NSRect rect = _detailViewController.view.frame;
    rect.origin.y -= rect.size.height;
    rect.size.height = 0;
    
    [_detailViewController.view.animator setFrame:rect];

    [self.view display];
}

-(void)showGroupDetails
{
    [self hideDetailView];
    
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    
    _detailViewController = [[AMGroupDetailsViewController alloc] initWithNibName:@"AMGroupDetailsViewController" bundle:nil];
    AMGroupDetailsViewController* gdc = (AMGroupDetailsViewController*)_detailViewController;
    gdc.group = model.selectedGroup;
    [gdc updateUI];
    
    [self.view addSubview:_detailViewController.view];
    
    NSRect rect = gdc.view.frame;
    NSRect topRect = self.topboundView.frame;
    rect.origin = topRect.origin;
    [_detailViewController.view setFrame:rect];
    
    rect.origin.y -= rect.size.height;
    [_detailViewController.view.animator setFrame:rect];
    [self.view display];
}

-(void)showUserDetails
{
    [self hideDetailView];
    
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    _detailViewController = [[AMUserDetailsViewController alloc] initWithNibName:@"AMUserDetailsViewController" bundle:nil];
    AMUserDetailsViewController* udc = (AMUserDetailsViewController*)_detailViewController;
    udc.user = model.selectedUser;
    
    [self.view addSubview:_detailViewController.view];
    
    NSRect rect = udc.view.frame;
    NSRect topRect = self.topboundView.frame;
    rect.origin = topRect.origin;
    [_detailViewController.view setFrame:rect];
    
    rect.origin.y -= rect.size.height;
    [_detailViewController.view.animator setFrame:rect];
    [udc updateUI];
    
   [self.view display];
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
            
            DetailPanelState newState = [[change objectForKey:@"new"] intValue];
            DetailPanelState oldState = [[change objectForKey:@"old"] intValue];
            
            if (newState == oldState) {
                return;
            }
            
            if (newState == DetailPanelGroup) {
                [self showGroupDetails];
                return;
            }
            
            if (newState == DetailPanelUser) {
                [self showUserDetails];
                return;
            }
            
            if (newState == DetailPanelHide) {
                [self hideDetailView];
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
