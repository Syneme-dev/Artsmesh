//
//  AMGroupPanelViewController.m
//  DemoUI
//
//  Created by Wei Wang on 6/27/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupPanelViewController.h"
#import "AMCoreData/AMCoreData.h"
#import "AMGroupPanelModel.h"
#import "AMGroupDetailsViewController.h"
#import "AMUserDetailsViewController.h"
#import "AMStaticGroupDetailsViewController.h"
#import "UIFramework/AMButtonHandler.h"
#import "AMLiveGroupDataSource.h"
#import "AMStaticGroupDataSource.h"
#import "AMStatusNet/AMStatusNet.h"
#import "AMStaticUserDetailsViewController.h"

@interface AMGroupPanelViewController ()<NSOutlineViewDelegate, NSOutlineViewDataSource>
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSButton *staticGroupTab;
@property (weak) IBOutlet NSButton *liveGroupTab;
@property (weak) IBOutlet NSTabView *groupTabView;
@property (weak) IBOutlet NSOutlineView *staticGroupOutlineView;

@property (strong)AMLiveGroupDataSource* liveGroupDataSource;
@property (strong)AMStaticGroupDataSource* staticGroupDataSource;

@end

@implementation AMGroupPanelViewController
{
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

-(void) awakeFromNib
{
    [AMButtonHandler changeTabTextColor:self.staticGroupTab toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.liveGroupTab toColor:UI_Color_blue];
    
    self.liveGroupDataSource = [[AMLiveGroupDataSource alloc] init];
    [self.liveGroupDataSource reloadGroups];
    [self.outlineView reloadData];
    self.outlineView.delegate = self.liveGroupDataSource;
    self.outlineView.dataSource  = self.liveGroupDataSource;
    [self.outlineView setTarget:self.liveGroupDataSource];
    [self.outlineView setDoubleAction:@selector(doubleClickOutlineView:)];
    
    self.staticGroupDataSource = [[AMStaticGroupDataSource alloc] init];
    [self.staticGroupDataSource reloadGroups];
    [self.staticGroupOutlineView reloadData];
    self.staticGroupOutlineView.delegate = self.staticGroupDataSource;
    self.staticGroupOutlineView.dataSource = self.staticGroupDataSource;
    [self.staticGroupOutlineView setTarget:self.staticGroupDataSource];
    [self.staticGroupOutlineView setDoubleAction:@selector(doubleClickOutlineView:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLiveGroups) name:AM_LIVE_GROUP_CHANDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshStaticGroups) name:AM_STATIC_GROUP_CHANGED object:nil];
    
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    [model addObserver:self forKeyPath:@"detailPanelState" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[AMGroupPanelModel sharedGroupModel] removeObserver:self];
}

-(void)reloadLiveGroups
{
    [self.liveGroupDataSource reloadGroups];
    [self.outlineView reloadData];
    [self.outlineView expandItem:nil expandChildren:YES];
}

-(void)hideDetailView
{
    if (_detailViewController) {
        [_detailViewController.view removeFromSuperview];
        _detailViewController = nil;
    }
}

-(void)showGroupDetails
{
    [self hideDetailView];
    
    AMGroupDetailsViewController* gdc = [[AMGroupDetailsViewController alloc] initWithNibName:@"AMGroupDetailsViewController" bundle:nil];
    
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    gdc.group = model.selectedGroup;
    [self.view addSubview:gdc.view];

    NSRect rect = gdc.view.frame;
    NSRect tabFrame = self.groupTabView.frame;
    rect.origin.x = tabFrame.origin.x;
    rect.origin.y = tabFrame.origin.y + tabFrame.size.height;
    rect.size.width = tabFrame.size.width;
    [gdc.view setFrame:rect];
    
    rect.origin.y -= rect.size.height;
    [gdc.view.animator setFrame:rect];
    
    [gdc updateUI];
    [self.view display];
    
    _detailViewController = gdc;
}

-(void)showUserDetails
{
     [self hideDetailView];
    
    AMUserDetailsViewController* udc = [[AMUserDetailsViewController alloc] initWithNibName:@"AMUserDetailsViewController" bundle:nil];
    
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    udc.user = model.selectedUser;
    [self.view addSubview:udc.view];
    
    NSRect rect = udc.view.frame;
    NSRect tabFrame = self.groupTabView.frame;
    rect.origin.x = tabFrame.origin.x;
    rect.origin.y = tabFrame.origin.y + tabFrame.size.height;
    rect.size.width = tabFrame.size.width;
    [udc.view setFrame:rect];
    
    rect.origin.y -= rect.size.height;
    [udc.view.animator setFrame:rect];
    
    [udc updateUI];
    [self.view display];
    
    _detailViewController = udc;
}

-(void)showStaticGroupDetailView
{
    [self hideDetailView];
    
    AMStaticGroupDetailsViewController* sdc = [[AMStaticGroupDetailsViewController alloc] initWithNibName:@"AMStaticGroupDetailsViewController" bundle:nil];
    
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    sdc.staticGroup = model.selectedStaticGroup;
    [self.view addSubview:sdc.view];
    
    NSRect rect = sdc.view.frame;
    NSRect tabFrame = self.groupTabView.frame;
    rect.origin.x = tabFrame.origin.x;
    rect.origin.y = tabFrame.origin.y + tabFrame.size.height;
    rect.size.width = tabFrame.size.width;
    [sdc.view setFrame:rect];
    
    rect.origin.y -= rect.size.height;
    [sdc.view.animator setFrame:rect];
    
    [self.view display];
    
    _detailViewController = sdc;
}

-(void)showStaticUserDetailView
{
    [self hideDetailView];
    
    AMStaticUserDetailsViewController* sudc = [[AMStaticUserDetailsViewController alloc] initWithNibName:@"AMStaticUserDetailsViewController" bundle:nil];
    
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    sudc.staticUser = model.selectedStaticUser;
    [self.view addSubview:sudc.view];
    
    NSRect rect = sudc.view.frame;
    NSRect tabFrame = self.groupTabView.frame;
    rect.origin.x = tabFrame.origin.x;
    rect.origin.y = tabFrame.origin.y + tabFrame.size.height;
    rect.size.width = tabFrame.size.width;
    [sudc.view setFrame:rect];
    
    rect.origin.y -= rect.size.height;
    [sudc.view.animator setFrame:rect];
    
    [self.view display];
    
    _detailViewController = sudc;
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
            
            if (newState == DetailPanelGroup) {
                [self showGroupDetails];
                return;
            }
            
            if (newState == DetailPanelUser) {
                [self showUserDetails];
                return;
            }
            
            if (newState == DetailPanelStaticGroup) {
                [self showStaticGroupDetailView];
                return;
            }
            
            if (newState == DetailPanelStaticUser) {
                [self showStaticUserDetailView];
                return;
            }
            
            if (newState == DetailPanelHide) {
                [self hideDetailView];
            }
        }
    }
}

#pragma mark-
#pragma StaticGroups

- (IBAction)staticGroupTabClick:(NSButton *)sender
{
    [self hideDetailView];
    [self.groupTabView selectTabViewItemAtIndex:1];
}

- (IBAction)liveGroupTabClick:(NSButton *)sender
{
    [self hideDetailView];
    [self.groupTabView selectTabViewItemAtIndex:0];
}

-(void)refreshStaticGroups
{
    [self.staticGroupDataSource reloadGroups];
    [self.staticGroupOutlineView reloadData];
    [self.staticGroupOutlineView expandItem:nil expandChildren:YES];
}


@end
