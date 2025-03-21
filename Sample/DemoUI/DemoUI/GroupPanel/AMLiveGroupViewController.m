//
//  AMLiveGroupViewController.m
//  DemoUI
//
//  Created by 王为 on 20/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMLiveGroupViewController.h"
#import "AMCoreData/AMCoreData.h"
#import "AMOutlineItem.h"
#import "AMLiveUserItem.h"
#import "AMOutlineCellContentView.h"
#import "UIFramework/NSView_Constrains.h"
#import "AMGroupOutlineRowView.h"
#import "AMGroupCellContentView.h"
#import "AMGroupItem.h"
#import "AMGroupDetailsViewController.h"
#import "AMUserDetailsViewController.h"
#import "AMMesher/AMMesher.h"

@interface AMLiveGroupViewController ()<NSOutlineViewDataSource, NSOutlineViewDelegate, AMGroupCellContentViewDelegate, AMGroupDetailViewDelegate>
@property (weak) IBOutlet NSOutlineView *outlineView;

@end

@implementation AMLiveGroupViewController
{
    AMOutlineItem *_rootItem;
    NSMutableArray* _expanededNodes;
    NSViewController* _detailViewController;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRemoteGroup:) name:AM_LIVE_GROUP_CHANDED object:nil];
    
    self.outlineView.dataSource = self;
    self.outlineView.delegate = self;
    
    [self loadRemoteGroup:nil];
}


-(void)viewWillAppear
{
    //[self loadLocalGroup:nil];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)loadRemoteGroup:(NSNotification *)notification
{
    _rootItem = [AMOutlineItem itemFromLabel:@"Artsmesh"];
    NSMutableArray *subItems = [[NSMutableArray alloc] init];
    _rootItem.subItems = subItems;
    _rootItem.shouldExpanded = YES;
    
    for (AMLiveGroup *liveGroup in [AMCoreData shareInstance].remoteLiveGroups) {
        AMGroupItem *groupItem = [AMGroupItem itemFromLiveGroup:liveGroup];
        [subItems addObject:groupItem];
    }
    
    //setExpanded
    //TODO:here if some group quit and never join again, its name will
    //stay in the expandedNode array, if the panel never close, the memory
    //wil contiuely growing. But if we have less than 1000 groups, we can ignore
    //that now
    for (AMOutlineItem *subItem in _rootItem.subItems) {
        if ([[self expandedNodes] containsObject:[subItem title]]) {
            subItem.shouldExpanded = YES;
            continue;
        }
        
        for (AMOutlineItem* subsubItem in subItem.subItems) {
            if ([[self expandedNodes] containsObject:[subsubItem title]]) {
                subsubItem.shouldExpanded = YES;
                break;
            }
        }
        
        //Always expanded my group
        AMLiveGroup *group = [AMCoreData shareInstance].myLocalLiveGroup;
        if ([subItem isKindOfClass:[AMGroupItem class]]) {
            if([[(AMGroupItem *)subItem groupData].groupId isEqualToString:group.groupId]){
                //
                subItem.shouldExpanded = YES;
                continue;
            }
        }
    }
    
    [_outlineView reloadData];
}


-(NSMutableArray*)expandedNodes
{
    if (_expanededNodes == nil) {
        _expanededNodes = [[NSMutableArray alloc] init];
    }
    
    return _expanededNodes;
}


#pragma mark AMGroupCellContentViewDelegate

-(void)infoBtnClickOnContentCellView:(AMGroupCellContentView *)contentCellView
{
    [self hideDetailView];
    
    if ([contentCellView.dataSource isKindOfClass:[AMGroupItem class]]) {
        
        AMGroupItem * groupItem = contentCellView.dataSource;
        if (groupItem) {
            AMGroupDetailsViewController* sdc = [[AMGroupDetailsViewController alloc] init];
            sdc.group = groupItem.groupData;
            sdc.hostVC = self;
            _detailViewController = sdc;
        }
        
    }else if ([contentCellView.dataSource isKindOfClass:[AMLiveUserItem class]]){
        
        AMLiveUserItem * userItem = contentCellView.dataSource;
        if (userItem) {
            AMUserDetailsViewController* sdc = [[AMUserDetailsViewController alloc] init];
            sdc.user = userItem.userData;
            sdc.hostVC = self;
            _detailViewController = sdc;
        }
    }
    
    if (_detailViewController) {
        [self.view addSubview:_detailViewController.view];
        
        _detailViewController.view.layer.backgroundColor = [[NSColor colorWithCalibratedRed:38.0/255.0 green:38.0/255.0 blue:38.0/255.0 alpha:0.95] CGColor];
        
        NSRect rect = _detailViewController.view.frame;
        NSRect tabFrame = self.view.frame;
        rect.origin.x = tabFrame.origin.x;
        rect.origin.y = tabFrame.origin.y + tabFrame.size.height;
        rect.size.width = tabFrame.size.width;
        [_detailViewController.view setFrame:rect];
        
        rect.origin.y -= rect.size.height;
        [_detailViewController.view.animator setFrame:rect];
        
        [self.view display];
        
    }
}


-(void)mergeBtnClickOnContentCellView:(AMGroupCellContentView *)contentCellView
{
    if ([contentCellView.dataSource isKindOfClass:[AMGroupItem class]]) {
        AMGroupItem *groupItem = (AMGroupItem *)contentCellView.dataSource;
        if (groupItem) {
            [[AMMesher sharedAMMesher] mergeGroup:groupItem.groupData.groupId];
        }
    }
}


-(void)leaveBtnClickOnContentCellView:(AMGroupCellContentView *)contentCellView
{
    [[AMMesher sharedAMMesher] mergeGroup:@""];
}

-(void)hideDetailView
{
    if (_detailViewController) {
        [_detailViewController.view removeFromSuperview];
        _detailViewController = nil;
    }
}


#pragma mark AMGroupDetailViewDelegate
-(void)resignDetailView:(NSViewController *)detailVC
{
    [self hideDetailView];
}


#pragma mark NSOutlineViewDataSource
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (_rootItem == nil) {
        return 0;
    }
    
    if (item == nil) {
        return 1;
    }
    
    if (![item isKindOfClass:[AMOutlineItem class]]) {
        return 0;
    }
    
    AMOutlineItem *outlineItem = (AMOutlineItem *)item;
    return [outlineItem.subItems count];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if([[item title] isEqualTo:@"Artsmesh"]){
        return YES;
    }
    
    long i =  [self outlineView:outlineView numberOfChildrenOfItem:item];
    return i > 0;
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (item == nil) {
        return _rootItem;
    }
    
    if (![item isKindOfClass:[AMOutlineItem class]]) {
        return nil;
    }
    
    AMOutlineItem *outlineItem = (AMOutlineItem *)item;
    return  [outlineItem.subItems objectAtIndex:index];
}


- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
    return 30.0;
}


- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    static NSString *cellIdentifier = @"localGroupCell";
    NSTableCellView *cellView = [self.outlineView makeViewWithIdentifier:cellIdentifier owner:self];
    
    if (cellView == nil)
    {
        NSRect cellFrame = [self.outlineView bounds];
        cellFrame.size.height = 25;
        
        cellView = [[NSTableCellView alloc] initWithFrame:cellFrame];
        [cellView setIdentifier:cellIdentifier];
    }
    
    for (NSView *subview in cellView.subviews) {
        if ([subview.identifier isEqualToString:@"1001"]) {
            [subview removeFromSuperview];
        }
    }
    
    AMOutlineCellContentView *cellContentView = nil;
    if ([item isKindOfClass:[AMLiveUserItem class]]) {
        cellContentView = [[AMUserCellContentView alloc] initWithFrame:cellView.bounds];
        
    }else if ([item isKindOfClass:[AMGroupItem class]]){
        cellContentView = [[AMGroupCellContentView alloc] initWithFrame:cellView.bounds];
        
    }else if([item isKindOfClass:[AMOutlineItem class]]){
        cellContentView = [[AMOutlineCellContentView alloc] initWithFrame:cellView.bounds];
        
    }
    
    if (cellView) {
        cellContentView.identifier = @"1001";
        cellContentView.dataSource = item;
        cellContentView.delegate = self;
        [cellContentView updateUI];
        
        [cellView addFullConstrainsToSubview:cellContentView];
    }
    
    return cellView;
}


- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item
{
    
    AMGroupOutlineRowView* rowView = [[AMGroupOutlineRowView alloc] init];
    
    if ([item isKindOfClass:[AMGroupItem class]]) {
        
        AMGroupItem *groupItem = (AMGroupItem *)item;
        if (groupItem.groupData.busy) {
            rowView.headImage = [NSImage imageNamed:@"group_lock"];
            rowView.alterHeadImage = [NSImage imageNamed:@"group_lock_expanded"];
        }else{
            rowView.headImage = [NSImage imageNamed:@"group_online"];
            rowView.alterHeadImage = [NSImage imageNamed:@"group_online_expanded"];
        }
    }else if([[item title] isEqualTo:@"Artsmesh"]){
        rowView.headImage = [NSImage imageNamed:@"group_offline"];
        rowView.alterHeadImage = [NSImage imageNamed:@"group_offline_expanded"];
    }
    
    return rowView;
}


- (void)outlineViewItemDidExpand:(NSNotification *)notification
{
    AMOutlineItem* item = [[notification userInfo]valueForKey:@"NSObject"];
    if (item != nil){
        item.shouldExpanded = YES;
        [[self expandedNodes] addObject:item.title];
    }
}


-(void)outlineViewItemDidCollapse:(NSNotification *)notification
{
    AMOutlineItem* item = [[notification userInfo]valueForKey:@"NSObject"];
    if (item != nil){
        item.shouldExpanded = NO;
        [[self expandedNodes] removeObject:item.title];
    }
}



@end
