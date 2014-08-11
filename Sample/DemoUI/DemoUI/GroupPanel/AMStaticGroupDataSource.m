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
#import "AMGroupPanelStaticLabelController.h"

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
    AMGroupPanelStaticLabelController* labelController = [[AMGroupPanelStaticLabelController alloc] initWithNibName:@"AMGroupPanelStaticLabelController" bundle:nil];
    
    NSMutableArray* groupControllers = [[NSMutableArray alloc] init];
    
//    NSArray* staticGroups =  [AMCoreData shareInstance].staticGroups;
//    NSArray* myStaticGroups = [AMCoreData shareInstance].myStaticGroups;
 
//    if (staticGroups != nil) {
//        if (myStaticGroups != nil) {
//            for(AMStaticGroup* msg in myStaticGroups){
//                AMGroupPanelStaticGroupCellController* gc = [self createGroupControllerWithGroup:msg];
//                gc.isMyGroup = YES;
//                
//                BOOL inserted = NO;
//                for (int i = 0; i < [groupControllers count]; i++) {
//                    AMGroupPanelStaticGroupCellController* tempg = groupControllers[i];
//                    if (gc.groupUserCount > tempg. groupUserCount) {
//                        [groupControllers insertObject:gc atIndex:i];
//                        inserted = YES;
//                        break;
//                    }
//                }
//                
//                if (inserted == NO) {
//                    [groupControllers addObject:gc];
//                }
//            }
//
//        }
//        
//        for(AMStaticGroup* sg in staticGroups){
//            
//            if ([self isMyGroup:sg]) {
//                continue;
//            }
//            
//            AMGroupPanelStaticGroupCellController* gc = [self createGroupControllerWithGroup:sg];
//            gc.isMyGroup = NO;
//            
//            BOOL inserted = NO;
//            for (int i = 0 ; i < [groupControllers count]; i++) {
//                AMGroupPanelStaticGroupCellController* tempg = groupControllers[i];
//                if (tempg.isMyGroup) {
//                    continue;
//                }
//                
//                if (gc.groupUserCount > tempg. groupUserCount) {
//                    [groupControllers insertObject:gc atIndex:i];
//                    inserted = YES;
//                    break;
//                }
//            }
//            
//            if (inserted == NO) {
//                [groupControllers addObject:gc];
//            }
//        }
//    }
    
    labelController.childrenController = groupControllers;
    
    NSMutableArray* statusNetControllers = [[NSMutableArray alloc] init];
    [statusNetControllers addObject:labelController ];
    
    self.staticGroupControllers = statusNetControllers;
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

-(AMGroupPanelStaticGroupCellController*)createGroupControllerWithGroup:(AMStaticGroup*)staticGroup
{
    AMGroupPanelStaticGroupCellController* groupController =
    [[AMGroupPanelStaticGroupCellController alloc] initWithNibName:@"AMGroupPanelStaticGroupCellController" bundle:nil];
    
    groupController.staticGroup = staticGroup;
    groupController.groupUserCount = [staticGroup.users count];
    
    if([staticGroup users] != nil){
        groupController.childrenController = [[NSMutableArray alloc] init];
        for (AMStaticUser* su in [staticGroup users]) {
            AMGroupPanelStaticUserCellController* userController =
            [[AMGroupPanelStaticUserCellController alloc] initWithNibName:@"AMGroupPanelStaticUserCellController" bundle:nil];
            
            userController.staticUser = su;
            [groupController.childrenController addObject:userController];
        }
    }

    return groupController;
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
        
        rowView.headImage = [NSImage imageNamed:@"group_offline"];
        rowView.alterHeadImage = [NSImage imageNamed:@"group_offline_expanded"];
    }
    
    return rowView;
}

@end
