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

@interface AMLocalGroupViewController ()<NSOutlineViewDataSource, NSOutlineViewDelegate>
@property (weak) IBOutlet NSOutlineView *outlineView;
@end

@implementation AMLocalGroupViewController
{
    AMOutlineItem *_rootItem;
    NSMutableArray* _expanededNodes;
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
    
    [self reloadData];
}


-(void)reloadData
{
    [_outlineView reloadData];
    for (int i = 0; i < [self.outlineView numberOfRows]; i++) {
        id item = [self.outlineView itemAtRow:i];
        
        if ([_expanededNodes containsObject:[item title]]) {
            [self.outlineView expandItem:item];
        }
    }
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
        rowView.headImage = [NSImage imageNamed:@"group_offline"];
        rowView.alterHeadImage = [NSImage imageNamed:@"group_offline_expanded"];
        
    }

//    if ([item isKindOfClass:[AMGroupPanelLabelCellController class]]) {
//        
//        rowView.headImage = [NSImage imageNamed:@"artsmesh_bar"];
//        rowView.alterHeadImage = [NSImage imageNamed:@"artsmesh_bar_expanded"];
//        
//    }else if([item isKindOfClass:[AMGroupPanelGroupCellController class]]){
//        
//        AMGroupPanelGroupCellController* groupController = (AMGroupPanelGroupCellController*)item;
//        if ([groupController.group isMeshed]) {
//            if (groupController.group.busy) {
//                rowView.headImage = [NSImage imageNamed:@"live_group_busy_vertical"];
//                rowView.alterHeadImage = [NSImage imageNamed:@"live_group_busy_horizen"];
//            }else{
//                rowView.headImage = [NSImage imageNamed:@"group_online"];
//                rowView.alterHeadImage = [NSImage imageNamed:@"group_online_expanded"];
//            }
//        }else{
//         
//        }
//    }
    
    return rowView;
}


@end
