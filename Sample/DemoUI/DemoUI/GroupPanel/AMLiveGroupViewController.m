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
#import "NSView_Constrains.h"
#import "AMGroupOutlineRowView.h"
#import "AMGroupCellContentView.h"
#import "AMGroupItem.h"

@interface AMLiveGroupViewController ()<NSOutlineViewDataSource, NSOutlineViewDelegate>
@property (weak) IBOutlet NSOutlineView *outlineView;

@end

@implementation AMLiveGroupViewController
{
    AMOutlineItem *_rootItem;
    NSMutableArray* _expanededNodes;
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

    if (![AMCoreData shareInstance].mySelf.isOnline) {
        _rootItem = nil;
        [_outlineView reloadData];
        return;
    }
    
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
    
    if ([item isKindOfClass:[AMGroupItem class]] ||
        [item isKindOfClass:[AMOutlineItem class]]) {
        rowView.headImage = [NSImage imageNamed:@"group_online"];
        rowView.alterHeadImage = [NSImage imageNamed:@"group_online_expanded"];
        
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
