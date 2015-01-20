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

@interface AMArchiveGroupViewController ()<NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (weak) IBOutlet NSOutlineView *outlineView;
@end

@implementation AMArchiveGroupViewController
{
    AMOutlineItem *_rootItem;
    NSMutableArray* _expanededNodes;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadLocalGroup:) name:AM_STATIC_GROUP_CHANGED object:nil];
    
    self.outlineView.dataSource = self;
    self.outlineView.delegate = self;
}

-(void)viewWillAppear
{
    [self loadLocalGroup:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)loadLocalGroup:(NSNotification *)notification
{
    _rootItem = [AMOutlineItem itemFromLabel:@"ARCHIVE"];
    NSMutableArray *subItems = [[NSMutableArray alloc] init];
    _rootItem.subItems = subItems;
    
    for (AMStaticGroup *sGroup in [AMCoreData shareInstance].staticGroups) {
        AMArchiveGroupItem *groupItem = [AMArchiveGroupItem itemFromArchiveGroup:sGroup];
        [subItems addObject:groupItem];
    }
    
    [_outlineView reloadData];
    [_outlineView expandItem:[self.outlineView itemAtRow:0] expandChildren:NO];
}


-(NSMutableArray*)expandedNodes
{
    if (_expanededNodes == nil) {
        _expanededNodes = [[NSMutableArray alloc] init];
    }
    
    return _expanededNodes;
}


-(BOOL)isMyGroup:(AMStaticGroup*)group
{
    NSArray* myGroups = [AMCoreData shareInstance].myStaticGroups;
    for (AMStaticGroup* g in myGroups)
    {
        if ([g.g_id integerValue] == [group.g_id integerValue]) {
            return YES;
        }
    }
    
    return NO;
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



@end
