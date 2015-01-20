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
#import "AMLocalGroupCellContentView.h"
#import "AMOutlineItem.h"
#import "AMLiveGroupItem.h"
#import "AMLiveUserItem.h"
#import "NSView_Constrains.h"
#import "AMGroupOutlineRowView.h"

@interface AMLocalGroupViewController ()<NSOutlineViewDataSource, NSOutlineViewDelegate>
@property (weak) IBOutlet NSOutlineView *outlineView;
@end

@implementation AMLocalGroupViewController
{
    AMLiveGroup *_localGroup;
    AMOutlineItem *_rootItem;
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
    AMLiveGroupItem *groupItem = [AMLiveGroupItem itemFromLiveGroup:liveGroup];
    _rootItem = groupItem;
    
    [_outlineView reloadData];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        
    }else if ([item isKindOfClass:[AMLiveGroupItem class]]){
        cellContentView = [[AMLocalGroupCellContentView alloc] initWithFrame:cellView.bounds];
        
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
    
    if ([item isKindOfClass:[AMLiveGroupItem class]]) {
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
