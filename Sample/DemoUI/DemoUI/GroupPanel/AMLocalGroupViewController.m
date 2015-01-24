//
//  AMLocalGroupViewController.m
//  DemoUI
//
//  Created by 王为 on 18/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMLocalGroupViewController.h"
#import "AMCoreData/AMCoreData.h"
#import "AMOutlineCellContentView.h"
#import "AMUserCellContentView.h"
#import "AMGroupCellContentView.h"
#import "AMOutlineItem.h"
#import "AMGroupItem.h"
#import "AMLiveUserItem.h"
#import "NSView_Constrains.h"
#import "AMGroupOutlineRowView.h"
#import "AMGroupDetailViewDelegate.h"
#import "AMGroupDetailsViewController.h"
#import "AMUserDetailsViewController.h"

@interface AMLocalGroupViewController ()<NSOutlineViewDataSource, NSOutlineViewDelegate, AMGroupCellContentViewDelegate, AMGroupDetailViewDelegate>
@property (weak) IBOutlet NSOutlineView *outlineView;
@end

@implementation AMLocalGroupViewController
{
    AMOutlineItem *_rootItem;
    NSMutableArray* _expanededNodes;
    NSViewController* _detailViewController;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadLocalGroup:) name:AM_LIVE_GROUP_CHANDED object:nil];
    
    self.outlineView.dataSource = self;
    self.outlineView.delegate = self;
}


-(void)viewWillAppear
{
    [self loadLocalGroup:nil];
}


-(void)loadLocalGroup:(NSNotification *)notification
{
    AMLiveGroup *liveGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    AMGroupItem *groupItem = [AMGroupItem itemFromLiveGroup:liveGroup];
    _rootItem = groupItem;
    _rootItem.shouldExpanded = YES;
    
    [self reloadData];
}


-(void)reloadData
{
    [_outlineView reloadData];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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


- (void)outlineViewItemDidExpand:(NSNotification *)notification
{
    AMOutlineItem* item = [[notification userInfo]valueForKey:@"NSObject"];
    if (item != nil){
        //item.isExpanded = YES;
        [[self expandedNodes] addObject:item.title];
    }
}


-(void)outlineViewItemDidCollapse:(NSNotification *)notification
{
    AMOutlineItem* item = [[notification userInfo]valueForKey:@"NSObject"];
    if (item != nil){
        //item.isExpanded = NO;
        [[self expandedNodes] removeObject:item.title];
    }
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
            rowView.headImage = [NSImage imageNamed:@"group_offline"];
            rowView.alterHeadImage = [NSImage imageNamed:@"group_offline_expanded"];
        }
    }
    
    return rowView;
}


@end
