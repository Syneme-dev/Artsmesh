//
//  AMStaticGroupDataSource.m
//  DemoUI
//
//  Created by 王 为 on 7/10/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMStaticGroupDataSource.h"
#import "AMGroupPanelTableCellView.h"
#import "AMGroupOutlineRowView.h"
#import "AMCoreData/AMCoreData.h"
#import "AMGroupPanelTableCellController.h"
#import "AMGroupPanelStaticGroupCellController.h"
#import "AMGroupPanelStaticUserCellController.h"

@implementation AMStaticGroupDataSource

-(void)doubleClickOutlineView:(id)sender
{
    if([sender isKindOfClass:[NSOutlineView class]]){
        NSOutlineView* ov = (NSOutlineView*)sender;
        NSInteger selected = [ov selectedRow];
        
        if (selected < 0){
            return;
        }
        
        AMGroupPanelTableCellView *selectedCellView = [ov viewAtColumn:0 row:selected makeIfNecessary:YES];
        [selectedCellView doubleClicked:self];
    }
}

-(void)reloadGroups
{
    NSArray* staticGroups =  [AMCoreData shareInstance].staticGroups;
    if (staticGroups == nil) {
        return;
    }
    
    NSMutableArray* groupControllers = [[NSMutableArray alloc] init];
    
    for(AMStaticGroup* sg in staticGroups){
        AMGroupPanelStaticGroupCellController* groupController =
        [[AMGroupPanelStaticGroupCellController alloc] initWithNibName:@"AMGroupPanelStaticGroupCellController" bundle:nil];
        
        groupController.staticGroup = sg;
        
        if([sg users] != nil){
            groupController.childrenController = [[NSMutableArray alloc] init];
            for (AMStaticUser* su in [sg users]) {
                AMGroupPanelStaticUserCellController* userController =
                [[AMGroupPanelStaticUserCellController alloc] initWithNibName:@"AMGroupPanelStaticUserCellController" bundle:nil];
                
                userController.staticUser = su;
                [groupController.childrenController addObject:userController];
            }
        }
        
        [groupControllers addObject:groupController];
    }
    
    self.staticGroupControllers = groupControllers;
}


- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return  [self.staticGroupControllers count];
    }else{
        return [[item childrenController] count];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    long i =  [self outlineView:outlineView numberOfChildrenOfItem:item];
    return i > 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (item == nil) {
        return self.staticGroupControllers[index];
    }else{
        return [item childrenController][index];
    }
        
    return nil;
}


- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    
    if ([item isKindOfClass:[AMGroupPanelTableCellController class]]) {
        AMGroupPanelTableCellController* staticController = (AMGroupPanelTableCellController*)item;
        [staticController updateUI];
        [staticController setTrackArea];
        
        return staticController.view;
    }

    return nil;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
    if ([item isKindOfClass:[AMGroupPanelTableCellController class]]) {
        AMGroupPanelTableCellController* controller = (AMGroupPanelTableCellController*) item;
        NSView* cellView = controller.view;
        
        return cellView.frame.size.height;
    }
    
    return 0.0;
}

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item
{
    AMGroupOutlineRowView* rowView = [[AMGroupOutlineRowView alloc] init];
    
    if ([item isKindOfClass:[AMGroupPanelTableCellController class]]) {
        
        rowView.headImage = [NSImage imageNamed:@"group_online"];
        rowView.alterHeadImage = [NSImage imageNamed:@"group_online_expanded"];
    }
    
    return rowView;
}

@end
