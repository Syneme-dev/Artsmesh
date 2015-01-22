//
//  AMArchiveGroupViewController.m
//  DemoUI
//
//  Created by 王为 on 20/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMArchiveGroupViewController.h"
#import "AMOutlineItem.h"
#import "AMCoreData/AMCoreData.h"
#import "AMGroupOutlineRowView.h"
#import "AMArchiveUserItem.h"
#import "AMArchiveGroupItem.h"
#import "AMArchiveCellContentView.h"
#import "NSView_Constrains.h"
#import "AMStatusNet/AMStatusNet.h"
#import "AMStaticGroupDetailsViewController.h"
#import "AMStaticUserDetailsViewController.h"
#import "AMNotificationManager/AMNotificationManager.h"

@interface AMArchiveGroupViewController ()<NSOutlineViewDataSource,
NSOutlineViewDelegate,
AMArchiveCellContentViewDelegate,
AMGroupDetailViewDelegate>

@property (weak) IBOutlet NSOutlineView *outlineView;
@end

@implementation AMArchiveGroupViewController
{
    AMOutlineItem *_rootItem;
    NSMutableArray* _expanededNodes;
    NSViewController* _detailViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadArchiveGroup:) name:AM_STATIC_GROUP_CHANGED object:nil];
    
    self.outlineView.dataSource = self;
    self.outlineView.delegate = self;
    
    [[AMStatusNet shareInstance] loadGroups];
}

-(void)viewWillAppear
{
    [self loadArchiveGroup:nil];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)loadArchiveGroup:(NSNotification *)notification
{
    _rootItem = [AMOutlineItem itemFromLabel:@"Archive Group"];
    NSMutableArray *subItems = [[NSMutableArray alloc] init];
    _rootItem.subItems = subItems;
    _rootItem.shouldExpanded = YES;
    
    for (AMStaticGroup *sGroup in [AMCoreData shareInstance].staticGroups) {
        AMArchiveGroupItem *groupItem = [AMArchiveGroupItem itemFromArchiveGroup:sGroup];
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


- (IBAction)refreshData:(id)sender
{
    [self loadArchiveGroup:nil];
}


#pragma mark AMGroupDetailViewDelegate
-(void)resignDetailView:(NSViewController *)detailVC
{
    [self hideDetailView];
}


#pragma mark AMArchiveCellContentViewDelegate

-(void)infoBtnClickOnContentCellView:(AMArchiveCellContentView *)contentCellView
{
    [self hideDetailView];
    
    if ([contentCellView.dataSource isKindOfClass:[AMArchiveGroupItem class]]) {
        
        AMArchiveGroupItem * groupItem = contentCellView.dataSource;
        if (groupItem) {
            AMStaticGroupDetailsViewController* sdc = [[AMStaticGroupDetailsViewController alloc] init];
            sdc.staticGroup = groupItem.archiveGroupData;
            sdc.hostVC = self;
            _detailViewController = sdc;
        }
        
    }else if ([contentCellView.dataSource isKindOfClass:[AMArchiveUserItem class]]){
        
        AMArchiveUserItem * userItem = contentCellView.dataSource;
        if (userItem) {
            AMStaticUserDetailsViewController* sdc = [[AMStaticUserDetailsViewController alloc] init];
            sdc.staticUser = userItem.userData;
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


-(void)socialBtnClickOnContentCellView:(AMArchiveCellContentView *)contentCellView
{
    if ([contentCellView.dataSource isKindOfClass:[AMArchiveGroupItem class]]) {
        
        AMArchiveGroupItem * groupItem = contentCellView.dataSource;
        if (groupItem) {
            NSString* groupName = groupItem.archiveGroupData.nickname;
            NSDictionary *userInfo= [[NSDictionary alloc] initWithObjectsAndKeys:
                                     groupName , @"GroupName", nil];
            [AMN_NOTIFICATION_MANAGER postMessage:userInfo withTypeName:AMN_SHOWGROUPINFO source:self];
        }
        
    }else if ([contentCellView.dataSource isKindOfClass:[AMArchiveUserItem class]]){
        
        AMArchiveUserItem * userItem = contentCellView.dataSource;
        if (userItem) {
   
            NSString* url = userItem.userData.statusnet_profile_url;
            NSDictionary *userInfo= [[NSDictionary alloc] initWithObjectsAndKeys:
                                     url , @"ProfileUrl", nil];
            [AMN_NOTIFICATION_MANAGER postMessage:userInfo withTypeName:AMN_SHOWUSERINFO source:self];
        }
    }
}


-(void)hideDetailView
{
    if (_detailViewController) {
        [_detailViewController.view removeFromSuperview];
        _detailViewController = nil;
    }
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
    if ([item isKindOfClass:[AMArchiveUserItem class]]) {
        cellContentView = [[AMArchiveCellContentView alloc] initWithFrame:cellView.bounds];
        
    }else if ([item isKindOfClass:[AMArchiveGroupItem class]]){
        cellContentView = [[AMArchiveCellContentView alloc] initWithFrame:cellView.bounds];
        
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
    
    if ([item isKindOfClass:[AMArchiveGroupItem class]] ||
        [item isKindOfClass:[AMOutlineItem class]]) {
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
