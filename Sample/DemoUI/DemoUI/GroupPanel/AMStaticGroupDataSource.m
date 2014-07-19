//
//  AMStaticGroupDataSource.m
//  DemoUI
//
//  Created by 王 为 on 7/10/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMStaticGroupDataSource.h"
#import "AMStaticGroupOutlineCellView.h"
#import "AMGroupOutlineRowView.h"
#import "AMCoreData/AMCoreData.h"
#import "AMGroupOutlineStaticCellViewController.h"

@implementation AMStaticGroupDataSource

-(void)doubleClickOutlineView:(id)sender
{
    if([sender isKindOfClass:[NSOutlineView class]]){
        NSOutlineView* ov = (NSOutlineView*)sender;
        NSInteger selected = [ov selectedRow];
        
        if (selected < 0){
            return;
        }
        
        AMStaticGroupOutlineCellView *selectedCellView = [ov viewAtColumn:0 row:selected makeIfNecessary:YES];
        [selectedCellView.infoBtn performClick:selectedCellView.infoBtn];
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
        AMGroupOutlineStaticCellViewController* groupController =
        [[AMGroupOutlineStaticCellViewController alloc] initWithNibName:@"AMStaticGroupOutlineCellViewController" bundle:nil];
        
        groupController.staticGroup = sg;
        groupController.staticUser = nil;
        
        if([sg users] != nil){
            groupController.userControllers = [[NSMutableArray alloc] init];
            for (AMStaticUser* su in [sg users]) {
                AMGroupOutlineStaticCellViewController* userController =
                [[AMGroupOutlineStaticCellViewController alloc] initWithNibName:@"AMStaticGroupOutlineCellViewController" bundle:nil];
                
                userController.staticGroup = sg;
                userController.staticUser = su;
                [groupController.userControllers addObject:userController];
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
        return [[item userControllers] count];
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
        return [item userControllers][index];
    }
        
    return nil;
}


- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    
    if ([item isKindOfClass:[AMGroupOutlineStaticCellViewController class]]) {
        AMGroupOutlineStaticCellViewController* staticController = (AMGroupOutlineStaticCellViewController*)item;
        [staticController updateUI];
        [staticController setTrackArea];
        
        return staticController.view;
    }

    return nil;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
    if ([item isKindOfClass:[NSViewController class]]) {
        NSViewController* controller = (NSViewController*) item;
        NSView* cellView = controller.view;
        
        return cellView.frame.size.height;
    }
    
    return 0.0;
}

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item
{
    AMGroupOutlineRowView* rowView = [[AMGroupOutlineRowView alloc] init];
    return rowView;
}

@end
